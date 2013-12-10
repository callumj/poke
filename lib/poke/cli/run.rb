module Poke
  module Cli
    class Run < Base

      self.visible_name = "run"

      def run
        Poke::BackgroundRunner.kickoff
      end

    end
  end
end