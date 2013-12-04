module Poke
  module Reporters
    class TemporaryTables < Base

      self.visible_name = "temporary_tables"

      def results_scope
        event_scope = Poke::SystemModels::QueryExecution.by_event("temporary")
        Poke::SystemModels::Query.join(event_scope, query_id: :id).order(Sequel.desc(:execution_time))
      end

    end
  end
end