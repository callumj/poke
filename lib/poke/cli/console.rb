module Poke
  module Cli
    class Console < Base

      class_attribute :visible_name
      self.visible_name = "console"

      def run
        info "Starting Pry instance"
        Bundler.require :default, :development
        Poke.system_db.logger = Logger.new(STDOUT)
        
        binding.pry
      end

    end
  end
end