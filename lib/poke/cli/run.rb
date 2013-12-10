module Poke
  module Cli
    class Run < Base

      self.visible_name = "run"
      self.description  = "Start the application"

      def run
        Poke::BackgroundRunner.kickoff
      end

    end
  end
end