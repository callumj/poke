module Poke

  def self.system_db_path
    ENV["SYSTEM_DB_PATH"] || "sqlite://#{APP_PATH}/system.db"
  end

  def self.db_options
    {}.tap do |hash|
      hash[:logger] = Logger.new("#{APP_PATH}/tmp/logs/db.log")
    end
  end

  def self.logger_path
    Config["logger_path"] || ENV["LOGGER_PATH"] || "#{APP_PATH}/tmp/logs/app.log"
  end

  def self.logger
    @logger ||= Logger.new(logger_path).tap do |log|
      log.formatter = proc do |severity, datetime, progname, msg|
         "#{datetime.to_s} [#{severity}]: #{msg}\n"
      end
    end
  end

  def self.system_db
    @system_db ||= Sequel.connect(system_db_path, db_options)
  end

  def self.target_db
    return unless Config["target_db_path"]
    @target_db ||= Sequel.connect(Config["target_db_path"], logger: Logger.new(STDOUT))
  end

  def self.init
    Sequel::Model.db = system_db
  end

end

require 'poke/config'
require 'poke/utils'
require 'poke/collectors'
require 'poke/analyzers'
require 'poke/runners'

Poke.init
require 'poke/system_models'