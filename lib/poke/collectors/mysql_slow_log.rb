module Poke
  module Collectors
    class MysqlSlowLog

      TBL_NAMESPACE = "`cj_testing`.`slow_log`"

      def self.target_scope
        Poke.target_db.fetch("SELECT * FROM #{TBL_NAMESPACE}")
      end

      def self.process_from_db
        max_time_point = Time.now.utc

        most_recent_occurred_time, most_recent_statements = Poke::SystemModels::Query.most_recent_statements

        Poke::Utils::DataPaging.mass_select(target_scope) do |result_batch|
          continue = true

          result_batch.each do |result|
            if result[:start_time] > max_time_point
              continue = false
              next
            else
              next if most_recent_occurred_time && ((result[:start_time] < most_recent_occurred_time) || (most_recent_occurred_time == result[:start_time] && most_recent_statements.include?(result[:sql_text])))
              
              query_time = result[:query_time].is_a?(Fixnum) ? result[:query_time] : result[:query_time].try(:seconds_since_midnight)
              lock_time  = result[:lock_time].is_a?(Fixnum) ? result[:lock_time] : result[:lock_time].try(:seconds_since_midnight)

              user_part, host_part = result[:user_host].split("@").map { |p| p.strip.gsub(/(.*\[)|(\].*)/, "") }

              hash = {
                occurred_at:    result[:start_time],
                execution_time: query_time,
                lock_time:      lock_time,
                rows_sent:      result[:rows_sent],
                rows_examined:  result[:rows_examined],
                schema:         result[:db],
                last_insert_id: result[:last_insert_id],
                insert_id:      result[:insert_id],
                server_id:      result[:server_id],
                statement:      result[:sql_text],
                user:           user_part,
                host:           host_part,
                collected_from: self.name
              }

              process_slow_entry hash
            end
          end

          continue
        end
      end

      def self.process_slow_entry(obj_hash)
        Poke::SystemModels::Query.conditionally_create obj_hash
      end

    end
  end
end
