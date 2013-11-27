File.expand_path("#{File.dirname(__FILE__)}/../tmp/testing.db")
ENV["SYSTEM_DB_PATH"] = "sqlite://#{File.expand_path("#{File.dirname(__FILE__)}/../tmp/testing.db")}"
load "#{File.dirname(__FILE__)}/../bootstrap.rb"

Bundler.require :default, :development, :testing

require 'rspec'
require 'database_cleaner'

RSpec.configure do |config|

  config.color_enabled = true
  config.mock_with :rspec

  config.before(:suite) do
    Poke::Utils::DbManagement.init_system_db true
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end