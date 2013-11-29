module Poke

  def self.storage_path
    ENV["POKE_APP_PATH"] || APP_PATH
  end

  def self.system_db_path
    ENV["POKE_SYSTEM_DB_PATH"] || "sqlite://#{storage_path}/db/system.db"
  end

  def self.logger_path(type)
    return nil if ENV["IN_TEST"]
    type_s = type.to_s.gsub(/\W+/, "_")
    Config["logger.#{type_s.downcase}.path"] || File.join(storage_path, "logs", "#{type_s.downcase}.log")
  end

  def self.logger_for(type)
    @cached_loggers       ||= {}

    @cached_loggers[type] ||= Logger.new(logger_path(type), 'weekly').tap do |log|
      log.level = Logger::WARN
      log.formatter = proc do |severity, datetime, progname, msg|
         "#{datetime.to_s} [#{severity}]: #{msg}\n"
      end
    end
  end

  def self.app_logger
    @app_logger ||= logger_for(:app)
  end

  def self.system_db
    @system_db ||= Sequel.connect(system_db_path)
  end

  def self.target_db
    return unless Config["target_db.path"]
    @target_db ||= Sequel.connect(Config["target_db.path"], logger: logger_for(:target_db))
  end

  def self.init
    require 'fileutils'
    FileUtils.mkdir_p File.join(storage_path, "logs")
    FileUtils.mkdir_p File.join(storage_path, "db")

    Utils::DbManagement.init_system_db false

    Sequel::Model.db = system_db

    require 'poke/system_models'

    system_db.logger = logger_for(:system_db)
  end

end

require 'poke/config'
require 'poke/utils'
require 'poke/collectors'
require 'poke/analyzers'
require 'poke/runners'
require 'poke/background_runner'

Poke.init