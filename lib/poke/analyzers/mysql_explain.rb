module Poke
  module Analyzers
    class MysqlExplain

      attr_reader :query

      def initialize(query)
        @query = query
      end

      def explainable_query
        @explainable_query ||= begin
          query.statement.gsub(/(BEGIN|COMMIT);?\s*/i, "").strip
        end
      end

      def explain_result
        @explain_result ||= begin
          db = Poke.target_db << "USE #{query.schema}"
          db["EXPLAIN #{explainable_query}"].all
        end
      end

      def executions
        @executions ||= explain_result.each_with_index.map do |res, order|
          {
            order:              order,
            select_method:      res[:select_type],
            index_method:       res[:ref],
            table:              res[:table],
            possible_indexes:   res[:possible_keys].try(:split, ",") || [],
            selected_index:     res[:key],
            index_length_used:  res[:key_len],
            rows_examined:      res[:rows],
            events:             sanitise_events(res[:Extra])
          }
        end
      end

      def self.sanitise_events(extras)
        extras.split(/;\s*/).map do |extra|
          extra.gsub(/^Using\s+/i, "")
        end
      end
      delegate :sanitise_events, to: 'self.class'

    end
  end
end