module Poke
  module Cli
    class Run < Base

      class_attribute :visible_name
      self.visible_name = "run"

      def run
        Poke::BackgroundRunner.kickoff
      end

    end
  end
end