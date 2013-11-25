module Poke
  module Collectors
    class MysqlSlowLog

      class Error < StandardError; end
      class SlowLogFileNotPresent < Error; end

      TBL_NAMESPACE = "`cj_testing`.`slow_log`"

      def self.target_scope
        Poke.target_db.fetch("SELECT * FROM #{TBL_NAMESPACE}")
      end
      delegate :target_scope, to: 'self.class'

      def self.process_slow_entry(obj_hash)
        Poke::SystemModels::Query.conditionally_create obj_hash
      end
      delegate :process_slow_entry, to: 'self.class'

      def process_from_file(target_file = Poke::Config["target_mysql_slow_log_file"])
        raise ArgumentError, "File not specified" unless target_file
        raise SlowLogFileNotPresent, "#{target_file} could not be located" unless File.exists?(target_file)

        current_db = nil
        context = nil
        File.foreach(target_file) do |line|
          if line.match(/^#\s+Time:\s+(.+)/)
            process_native_entry context.merge({db: current_db}) if context && context[:sql_text].present?

            # begin the context
            extracted_timing = $1
            time_portion = Time.parse("#{extracted_timing} UTC")
            context = {start_time: time_portion}
          else
            # not ready to parse
            next unless context

            case line
            when /^#\s+User\@Host:\s+(.+)/
              matched = $1
              user_host = matched.gsub(/\][^\]]+$/, "]")
              server_id = matched.match(/Id:\s+(\d+)/).try(:[], 1)
              context.merge!({user_host: user_host, server_id: server_id.try(:to_i)})
            when /^#\s+Query_time:\s+([\d\.]+)\s+Lock_time:\s+([\d\.]+)\s+Rows_sent:\s+([\d\.]+)\s+Rows_examined:\s+([\d\.]+)/i
              context.merge!({query_time: $1.to_f, lock_time: $2.to_f, rows_sent: $3.to_i, rows_examined: $4.to_i})
            when /^use\s+([^;]+)/i
              current_db = $1
            when /^SET\s+timestamp=(\d+)/i
              context.merge!({start_time: Time.at($1.to_i)})
            when /^(BEGIN|SELECT|COMMIT)/i
              current_sql = context[:sql_text] || ""
              current_sql << ";" unless current_sql.empty? || current_sql.last == ";"
              current_sql << line.strip
              context.merge!({sql_text: current_sql})
            end

          end
        end

        # finalise
        process_native_entry context.merge({db: current_db}) if context
      end

      def process_from_db
        max_time_point = Time.now.utc

        most_recent_occurred_time, most_recent_statements = Poke::SystemModels::Query.most_recent_statements

        Poke::Utils::DataPaging.mass_select(target_scope) do |result_batch|
          continue = true

          result_batch.each do |result|
            if result[:start_time] > max_time_point
              continue = false
              next
            else
              process_native_entry result
            end
          end

          continue
        end
      end

      def process_native_entry(native_hash)
        return if most_recent_occurred_time && ((native_hash[:start_time] < most_recent_occurred_time) || (most_recent_occurred_time == native_hash[:start_time] && most_recent_statements.include?(native_hash[:sql_text])))

        query_time = native_hash[:query_time].is_a?(Numeric) ? native_hash[:query_time] : native_hash[:query_time].try(:seconds_since_midnight)
        lock_time  = native_hash[:lock_time].is_a?(Numeric) ? native_hash[:lock_time] : native_hash[:lock_time].try(:seconds_since_midnight)

        user_part, host_part = extract_auth_details native_hash[:user_host]

        hash = {
          occurred_at:    native_hash[:start_time],
          execution_time: query_time,
          lock_time:      lock_time,
          rows_sent:      native_hash[:rows_sent],
          rows_examined:  native_hash[:rows_examined],
          schema:         native_hash[:db],
          last_insert_id: native_hash[:last_insert_id],
          insert_id:      native_hash[:insert_id],
          server_id:      native_hash[:server_id],
          statement:      native_hash[:sql_text],
          user:           user_part,
          host:           host_part,
          collected_from: self.class.name
        }

        process_slow_entry hash
      end

      private

        def most_recent_query
          @most_recent_query ||= Poke::SystemModels::Query.most_recent_statements
        end

        def most_recent_occurred_time
          most_recent_query.try :first
        end

        def most_recent_statements
          most_recent_query.try :last
        end

        def extract_auth_details(string)
          string.split("@").map { |p| p.strip.gsub(/(.*\[)|(\].*)/, "") }
        end

    end
  end
end
