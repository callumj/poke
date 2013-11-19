require 'digest'

module Poke
  module SystemModels
    class Config < Sequel::Model

      CACHE_TIME_FRAME = 2.minutes

      def self.cached_hash
        if @cached_last.nil? || (Time.now.utc - @cached_last) >= CACHE_TIME_FRAME
          @cached_hash = as_hash
          @cached_last = Time.now.utc
        end
        @cached_hash
      end

      def self.as_hash
        hash = {}
        all.each do |obj|
          hash[obj.key] = obj.value
        end
        hash
      end

    end
  end
end
