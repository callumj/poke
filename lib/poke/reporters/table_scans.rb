module Poke
  module Reporters
    class TableScans < Base

      self.visible_name = "table_scans"

      def results_scope
        event_scope = Poke::SystemModels::QueryExecution.by_join_method "ALL"
        Poke::SystemModels::Query.join(event_scope, query_id: :id).order(Sequel.desc(:execution_time)).select_all(Poke::SystemModels::Query.table_name)
      end

    end
  end
end