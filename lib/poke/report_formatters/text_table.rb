require 'terminal-table'

module Poke
  module ReportFormatters
    class TextTable < Csv

      self.visible_name = "text_table"

      def to_s
        @string ||= begin
          header = as_array.delete_at 0
          inst = Terminal::Table.new rows: as_array, heading: header
          inst.to_s
        end
      end

    end
  end
end