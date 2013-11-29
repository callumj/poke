module Poke
  module Runners
    class Base

      attr_reader :logger

      def initialize
        @logger = Poke.app_logger
      end

    end
  end
end