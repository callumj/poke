module Poke

  def self.system_db_path
    ENV["SYSTEM_DB_PATH"] || "sqlite://#{APP_PATH}/system.db"
  end

  def self.db_options
    {}.tap do |hash|
      hash[:logger] = Logger.new("#{APP_PATH}/tmp/logs/db.log")
    end
  end

  def self.system_db
    @system_db ||= Sequel.connect(system_db_path, db_options)
  end

  def self.target_db
    @target_db ||= Sequel.connect(Config["target_db_path"], logger: Logger.new(STDOUT))
  end

  def self.init
    Sequel::Model.db = system_db
  end

end

require 'poke/config'
require 'poke/utils'
require 'poke/collectors'

Poke.init
require 'poke/system_models'