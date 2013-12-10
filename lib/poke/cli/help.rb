module Poke
  module Cli
    class Help < Base

      self.visible_name = "help"
      self.description  = "List the available actions"

      def run
        error "Usage: poke ACTION [options]"
        error "The available actions are"
        Base.available_implementations.each do |name, klass|
          additional = "".tap do |str|
            str << " - #{klass.description}" if klass.description
          end
          error " * #{name}#{additional}"
        end
      end

    end
  end
end