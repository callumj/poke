module Poke
  module Analyzers
    class MysqlExplain

      attr_reader :query

      def self.run(options = {})
        limit      = options.fetch(:limit, 50)
        sleep_time = options[:sleep]
        scope = queries_needing_explain.limit(limit)

        results = scope.to_a
        until results.empty?
          results.each { |q| new(q).attach_to_query }

          sleep sleep_time if sleep_time
          min_id = results.map(&:id).min
          results = scope.where("`#{Poke::SystemModels::Query.table_name.to_s}`.`id` < #{min_id}").to_a
        end
      end

      def self.queries_needing_explain
        query = Poke::SystemModels::Query.ordered.left_join(Poke::SystemModels::QueryExecution, query_id: :id)
        query.where("`#{Poke::SystemModels::QueryExecution.table_name.to_s}`.`query_id` IS NULL").select_all(:queries)
      end

      def initialize(query)
        @query = query
      end

      def attach_to_query
        max_order = -1
        executions.each do |hash|
          existing = query.query_executions.eager(:execution_events).detect { |exec| exec.order == hash[:order] }
          if existing
            existing.update(hash.except(:events))

            # attach events
            event_names = hash[:events]
            existing_event_names = existing.events
            new_events = event_names - existing_event_names
            deleteable_events = existing_event_names - event_names

            new_events.each do |event_name|
              existing.add_execution_event Poke::SystemModels::ExecutionEvent.conditionally_create event_name
            end

            deleteable_events.each do |event_name|
              existing.remove_execution_event Poke::SystemModels::ExecutionEvent.conditionally_create event_name
            end
          else
            query.add_query_execution hash
          end

          max_order = hash[:order] if hash[:order] > max_order
        end

        # kill off remaining
        query.query_executions.each do |q|
          q.delete if q.order > max_order
        end
      end

      def explainable_query
        @explainable_query ||= begin
          query.statement.gsub(/(BEGIN|COMMIT);?\s*/i, "").strip
        end
      end

      def explain_result
        @explain_result ||= begin
          db = Poke.target_db << "USE `#{query.schema}`"
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
            possible_indexes:   res[:possible_keys].try(:split, /,\s*/) || [],
            selected_index:     res[:key],
            index_length_used:  res[:key_len],
            rows_examined:      res[:rows],
            events:             sanitise_events(res[:Extra])
          }
        end
      end

      def self.sanitise_events(extras)
        return [] unless extras.present?
        extras.split(/;\s*/).map do |extra|
          extra.gsub(/^Using\s+/i, "")
        end
      end
      delegate :sanitise_events, to: 'self.class'

    end
  end
end