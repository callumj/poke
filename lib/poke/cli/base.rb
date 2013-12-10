module Poke
  module Cli
    class Base

      include ActiveSupport::DescendantsTracker

      class_attribute :visible_name
      class_attribute :description
      
      self.visible_name = nil
      self.description  = nil

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

      def error(message)
        @error_logger ||= Logger.new(STDERR).tap do |l| 
          l.level = Logger::ERROR
          l.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\r\n"
          end
        end
        @error_logger.error message
      end

      def info(message)
        @info_logger ||= Logger.new(STDOUT).tap do |l| 
          l.level = Logger::INFO
          l.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\r\n"
          end
        end
        @info_logger.info message
      end

    end
  end
end