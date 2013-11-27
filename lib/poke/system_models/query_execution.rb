module Poke
  module SystemModels
    class QueryExecution < Sequel::Model
      many_to_one :query, class: "Poke::SystemModels::Query"

      many_to_many :execution_events, class: "Poke::SystemModels::ExecutionEvent", join_table: :query_execution_events, left_key: :query_execution_id, right_key: :execution_event_id
    end
  end
end