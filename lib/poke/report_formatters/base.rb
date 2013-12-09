module Poke
  module ReportFormatters
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

      attr_reader :options, :reporter

      def initialize(opts = {})
        raise ArgumentError, "Report instance must be provided by :reporter" unless opts[:reporter].is_a?(Poke::Reporters::Base)
        @reporter = opts.delete :reporter
        @options  = opts
      end

      def to_s
        raise NotImplementedError, "Must be implemented by subclass"
      end

      def to_file(f_descriptor)
        f_descriptor.write to_s
      end

    end
  end
end