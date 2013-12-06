module Poke
  module Cli
    class Base

      include ActiveSupport::DescendantsTracker

      class_attribute :visible_name
      self.visible_name = nil

      def self.available_implementations
        descendants.each_with_object({}) do |klass, hash|
          next unless klass.visible_name
          hash[klass.visible_name] = klass
        end
      end

      attr_reader :arg_list

      def initialize(arg_list)
        @arg_list = arg_list
      end

    end
  end
end