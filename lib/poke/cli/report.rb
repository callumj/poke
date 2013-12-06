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
          exit 1
        end

        formatters = Poke::ReportFormatters::Base.available_implementations
        formatter = formatters[format]

        unless formatter
          STDERR.puts "Must provide a valid format:"
          formatters.each do |name, klass|
            STDERR.puts " * #{name}"
          end
          exit 1
        end
        
        report = klass.new
        formatter.new(reporter: report).to_s
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

      def report_name
        @report_name ||= arg_list[0]
      end

      def format
        options[:format] || "text_table"
      end

    end
  end
end