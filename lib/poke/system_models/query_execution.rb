module Poke
  module SystemModels
    class QueryExecution < Sequel::Model
      many_to_one :query, class: "Poke::SystemModels::Query"

      many_to_many :execution_events, class: "Poke::SystemModels::ExecutionEvent", join_table: :query_execution_events, left_key: :query_execution_id, right_key: :execution_event_id

      def before_save
        set_hashes
        super
      end

      def set_hashes  
        self.select_method_hash = CityHash.hash64(self.select_method)  if self.select_method
        self.index_method_hash   = CityHash.hash64(self.index_method)   if self.index_method
        self.selected_index_hash = CityHash.hash64(self.selected_index) if self.selected_index
      end
    end
  end
end