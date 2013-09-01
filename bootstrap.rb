APP_PATH = File.dirname(__FILE__)

require 'bundler'
Bundler.require :default, :development

$:.unshift File.join(APP_PATH, "lib")

require 'active_support/all'
require 'poke'
