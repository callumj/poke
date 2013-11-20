File.expand_path("#{File.dirname(__FILE__)}/../tmp/testing.db")
ENV["SYSTEM_DB_PATH"] = "sqlite://#{File.expand_path("#{File.dirname(__FILE__)}/../tmp/testing.db")}"
load "#{File.dirname(__FILE__)}/../bootstrap.rb"

Poke::Utils::DbManagement.init_system_db true

Bundler.require :default, :development, :testing

require 'rspec'
require 'database_cleaner'

RSpec.configure do |config|

  config.color_enabled = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end