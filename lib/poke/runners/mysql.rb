module Poke
  module Runners
    class Mysql < Base

      CONFIG_NAMESPACE = "mysql"

      def run
        if Poke.target_db.nil?
          logger.error "No target database configured. Finishing."
          return
        elsif Poke.target_db.adapter_scheme.to_s.match(/^msyql/).present?
          logger.error "This should only be called on MySQL connections"
          return
        end

        logger.info "Starting to obtain new queries"
        obtain_queries
        logger.info "Finished obtain new queries"

        logger.info "Starting query analyzing"
        run_analyzer
        logger.info "Finished query analyzing"
      end

      private

        def obtain_queries
          mode = Poke::Config["#{CONFIG_NAMESPACE}.collection_mode"]
          return unless mode

          op = Poke::Collectors::MysqlSlowLog.new
          case mode
          when "file"
            begin
              op.process_from_file Poke::Config["#{CONFIG_NAMESPACE}.slow_log_file"]
            rescue ArgumentError, Poke::Collectors::MysqlSlowLog::SlowLogFileNotPresent => e
              logger.error "Could not collect from slow log file. #{e.message}"              
            end
          when "table"
            op.process_from_db
          end
        end

        def run_analyzer
          return if Poke::Config["#{CONFIG_NAMESPACE}.analyze_enabled"] == false
          Poke::Analyzers::MysqlExplain.run limit: Poke::Config["#{CONFIG_NAMESPACE}.analyze.limit"], sleep: Poke::Config["#{CONFIG_NAMESPACE}.analyze.sleep"]
        end

    end
  end
end