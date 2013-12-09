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

      def options
        @options ||= begin
          joined = arg_list[1..arg_list.length].join(" ")
          split = joined.split(/(\w+)\:/)
          split.delete_at 0
          split = split.map { |s| s.strip }
          Hash[*split].with_indifferent_access
        end
      end

    end
  end
end