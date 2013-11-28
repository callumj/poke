module Poke
  module SystemModels
    class QueryExecution < Sequel::Model
      many_to_one :query, class: "Poke::SystemModels::Query"

      many_to_many :execution_events, class: "Poke::SystemModels::ExecutionEvent", join_table: :query_execution_events, left_key: :query_execution_id, right_key: :execution_event_id

      def possible_indexes
        @possible_indexes ||= begin
          if self.possible_indexes_serialized
            JSON.parse(self.possible_indexes_serialized)
          else
            []
          end
        end
      end

      def possible_indexes=(val)
        raise ArgumentError, "Must be an Array or nil" unless val.is_a?(Array) || val.nil?
        val = [] if val.nil?
        @possible_indexes = val
      end

      def events
        @events ||= execution_events.map(&:name)
      end

      def events=(set)
        raise "Can only be set on new records" unless new?
        @events_to_write = Array.wrap(set)
      end

      def before_save
        set_hashes
        reflect_possible_indexes
        super
      end

      def after_save
        apply_events
      end

      def set_hashes  
        self.select_method_hash  = CityHash.hash64(self.select_method)  if self.select_method
        self.index_method_hash   = CityHash.hash64(self.index_method)   if self.index_method
        self.selected_index_hash = CityHash.hash64(self.selected_index) if self.selected_index
        self.join_method_hash    = CityHash.hash64(self.join_method) if self.join_method
      end

      def reflect_possible_indexes
        self.possible_indexes_serialized = @possible_indexes.try(:to_json) if defined?(@possible_indexes)
      end

      def apply_events
        return unless @events_to_write

        @events_to_write.each do |event_name|
          add_execution_event Poke::SystemModels::ExecutionEvent.conditionally_create event_name
        end
        @events_to_write = nil
      end
    end
  end
end