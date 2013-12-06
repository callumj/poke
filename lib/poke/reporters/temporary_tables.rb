module Poke
  module Reporters
    class TemporaryTables < Base

      self.visible_name = "temporary_tables"

      def justification_for(query)
        joins_using_temporary = query.query_executions.select { |qe| qe.events.include?("temporary") }.map(&:table)
        "Temporary table occurred on #{joins_using_temporary.join(", ")}"
      end

      def results_scope
        event_scope = Poke::SystemModels::QueryExecution.by_event("temporary")
        Poke::SystemModels::Query.with_core.join(event_scope, query_id: :id).order(Sequel.desc(:execution_time)).select_all(Poke::SystemModels::Query.table_name)
      end

    end
  end
end