module Poke
  module Reporters
    class Base

      class_attribute :visible_name
      self.visible_name = nil

      def self.available_implementations
        subclasses.each_with_object({}) do |klass, hash|
          next unless klass.visible_name
          hash[klass.visible_name] = klass
        end
      end

      attr_reader :options

      def initialize(opts = {})
        @options = opts
      end

      def results_scope
        raise NotImplementedError, "Must be implemented by subclass"
      end

    end
  end
end