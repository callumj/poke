File.expand_path("#{File.dirname(__FILE__)}/../tmp/testing.db")
ENV["SYSTEM_DB_PATH"] = "sqlite://#{File.expand_path("#{File.dirname(__FILE__)}/../tmp/testing.db")}"
load "#{File.dirname(__FILE__)}/../bootstrap.rb"

Poke::Utils::DbManagement.init_system_db true

require 'rspec'