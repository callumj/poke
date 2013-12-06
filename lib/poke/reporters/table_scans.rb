module Poke
  module Reporters
    class TableScans < Base

      self.visible_name = "table_scans"

      def justification_for(query)
        joins_using_temporary = query.query_executions.select { |qe| qe.join_method == "ALL" }.map(&:table)
        "Table scan occurred on #{joins_using_temporary.join(", ")}"
      end

      def results_scope
        event_scope = Poke::SystemModels::QueryExecution.by_join_method "ALL"
        Poke::SystemModels::Query.with_core.join(event_scope, query_id: :id).order(Sequel.desc(:execution_time)).select_all(Poke::SystemModels::Query.table_name)
      end

    end
  end
end