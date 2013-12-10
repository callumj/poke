module Poke
  class BackgroundRunner < Thread

    class Error < StandardError; end
    class AlreadyRunningError < Error; end

    SLEEP_BETWEEN = 10.seconds

    attr_accessor :to_be_killed
    attr_reader   :runner

    def self.active_thread
      @active_thread
    end

    def self.kickoff(no_join = false)
      if active_thread && active_thread.alive?
        Poke.app_logger.error "Runner is active, will not start"
        raise AlreadyRunningError, "Active thread is currently running"
      end

      runner = Poke::Runners.runner
      if runner.nil?
        Poke.app_logger.error "Will not start background thread, no runner available."
      else
        @active_thread = new(runner)
        active_thread.join unless no_join
      end
    end

    def self.packdown
      return unless active_thread
      active_thread.to_be_killed = true
    end

    def self.restart
      packdown
      kickoff
    end

    def initialize(runner_class)
      self.to_be_killed = false
      @runner = runner_class.new
      super do
        thread_runner
      end
    end

    def thread_runner
      perform_task
    end

    def perform_task
      while !to_be_killed do
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