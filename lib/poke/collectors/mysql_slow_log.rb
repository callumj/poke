module Poke
  module Collectors
    class MysqlSlowLog

      TBL_NAMESPACE = "`cj_testing`.`slow_log`"

      def self.target_scope
        Poke.target_db.fetch("SELECT * FROM #{TBL_NAMESPACE}")
      end

      def self.process_from_db
        max_time_point = Time.now.utc

        Poke::Utils::DataPaging.mass_select(target_scope) do |result_batch|
          continue = true

          result_batch.each do |result|
            if result[:start_time] > max_time_point
              continue = false
              next
            else
              query_time = result[:query_time].is_a?(Fixnum) ? result[:query_time] : result[:query_time].try :seconds_since_midnight
              lock_time  = result[:lock_time].is_a?(Fixnum) ? result[:lock_time] : result[:lock_time].try :seconds_since_midnight

              hash = {
                occurred_at:    result[:start_time],
                execution_time: query_time,
              }
            end
          end

          continue
        end
      end

      def self.process_slow_entry(args = {})

      end

    end
  end
end
