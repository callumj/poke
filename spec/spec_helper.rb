db_path = File.expand_path("#{File.dirname(__FILE__)}/../tmp/testing.db")
ENV["IN_TEST"] = "true"
ENV["POKE_SYSTEM_DB_PATH"] = "sqlite://#{db_path}"
load "#{File.dirname(__FILE__)}/../bootstrap.rb"

STDOUT.puts "Using DB: #{ENV["POKE_SYSTEM_DB_PATH"]}"

Bundler.require :default, :development, :testing

require 'rspec'
require 'database_cleaner'

RSpec.configure do |config|

  config.formatter     = :documentation
  config.color_enabled = true
  
  config.mock_with :rspec

  config.before(:suite) do
    Poke::Utils::DbManagement.init_system_db true
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    Poke::SystemModels::ExecutionEvent.event_cache.clear
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end