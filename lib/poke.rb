module Poke

  def self.system_db_path
    ENV["SYSTEM_DB_PATH"] || "sqlite://#{APP_PATH}/system.db"
  end

  def self.system_db
    @system_db ||= Sequel.connect(system_db_path)
  end

  def self.init
    Sequel::Model.db = system_db
  end

end

Poke.init

require 'poke/system_models'