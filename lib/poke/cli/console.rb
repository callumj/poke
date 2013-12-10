module Poke
  module Cli
    class Console < Base

      self.visible_name = "console"
      self.description  = "Starts a console instance with full access to Poke"

      def run
        info "Starting Pry instance"
        Bundler.require :default, :development
        Poke.system_db.logger = Logger.new(STDOUT)
        
        binding.pry
      end

    end
  end
end