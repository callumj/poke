module Poke
  class BackgroundRunner < Thread

    SLEEP_BETWEEN = 10.seconds

    attr_accessor :to_be_killed
    attr_reader   :runner

    def self.kickoff
      if Poke.target_db.nil?
        Poke.logger.error "Will not start background thread, no DB configured."
        return
      end

      @active_thread = nil

      # kick off
      case Poke.target_db.adapter_scheme.to_s
      when /^mysql/
        @active_thread = new Poke::Runners::Mysql
      end

      @active_thread.try :join
    end

    def self.packdown
      return unless @active_thread
      @active_thread.to_be_killed = true
    end

    def self.restart
      packdown
      kickoff
    end

    def initialize(runner_class)
      self.to_be_killed = false
      @runner = runner_class.new
      super do
        perform_task
      end
    end

    def perform_task
      while true do
        runner.run

        if to_be_killed
          break
        else
          sleep SLEEP_BETWEEN
        end
      end
    end

  end
end