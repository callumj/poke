module Poke
  module Cli
    class Report < Base

      class_attribute :visible_name
      self.visible_name = "report"

      def run
        reporters = Poke::Reporters::Base.available_implementations
        if report_name.nil? || (klass = reporters[report_name]).nil?
          STDERR.puts "Must provide a report name to run"
          reporters.each do |name, klass|
            STDERR.puts " * #{name}"
          end
          return false
        end

        formatters = Poke::ReportFormatters::Base.available_implementations
        formatter = formatters[format]

        unless formatter
          STDERR.puts "Must provide a valid format:"
          formatters.each do |name, klass|
            STDERR.puts " * #{name}"
          end
          return false
        end

        # force a data collection run
        if (runner = Poke::Runners.runner)
          runner.new.run
        else
          STDERR.puts "No available runners for target database"
          return false
        end

        report = klass.new
        formatter.new(reporter: report).to_s
      end

      def report_name
        @report_name ||= arg_list[0]
      end

      def format
        options[:format] || "text_table"
      end

    end
  end
end