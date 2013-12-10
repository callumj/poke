require 'sinatra/base'

module Poke
  module Web
    class Core < Sinatra::Base

      set :root, File.join(APP_PATH, "lib", "poke", "web")

      get "/" do
        erb :index
      end

    end
  end
end