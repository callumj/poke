module Poke
  module Runners
    class Base

      attr_reader :logger

      def initialize
        @logger = Poke.logger
      end

    end
  end
end