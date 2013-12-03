module Poke
  module Reporters
    class TemporaryTables < Base

      self.visible_name = "temporary_tables"

      def max_results
        options.fetch(:max, 50)
      end

      def results
        results_scope.order(Sequel.desc(:execution_time)).limit(max_results)
      end

      def results_scope
        Poke::SystemModels::Query.join(Poke::SystemModels::QueryExecution.by_event("temporary"), query_id: :id)
      end

    end
  end
end