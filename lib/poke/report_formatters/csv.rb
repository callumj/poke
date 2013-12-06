require 'csv'

module Poke
  module ReportFormatters
    class Csv < Base
      self.visible_name = "csv"

      def to_s
        @string ||= CSV.generate do |csv|
          as_array.each { |row| csv << row }
        end
      end

      private

        def as_array
          @array ||= reporter.results.each_with_object([["ID", "execution time", "schema", "statement", "notes"]]) do |query, ary|
            ary << [query.id, query.execution_time, query.schema, query.statement, reporter.justification_for(query)]
          end
        end

    end
  end
end