require 'sinatra/base'
require 'sass'

module Poke
  module Web
    class Core < Sinatra::Base

      set :root, File.join(APP_PATH, "lib", "poke", "web")

      get "/" do
        @slowest_queries = Poke::SystemModels::Query.last_period.limit(25).all
        erb :index
      end

      get "/stylesheets/:sheet_path.css" do
        path = params[:sheet_path].gsub(/\.\.+/, "")
        
        content_type 'text/css', charset: 'utf-8'
        scss :"stylesheets/#{path}"
      end

    end
  end
end