module Poke
  module Cli
    class Run < Base

      self.visible_name = "run"
      self.description  = "Start the application"

      def run
        Poke::BackgroundRunner.kickoff true
        Poke::Web::Core.run!
      end

    end
  end
end