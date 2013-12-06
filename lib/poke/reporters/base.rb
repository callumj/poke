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

      def results
        results_scope.limit(page_size, page_offset).all
      end

      def results_scope
        raise NotImplementedError, "Must be implemented by subclass"
      end

      def justification_for(obj)
        nil
      end

      private

        def page
          options.fetch(:page, 1)
        end

        def page_offset
          [page - page_size, 0].max
        end

        def page_size
          options.fetch(:limit, 50)
        end

    end
  end
end