require 'cityhash'

module Poke
  module SystemModels
    class ExecutionEvent < Sequel::Model

      def self.event_cache
        @event_cache ||= {}
      end
      delegate :event_cache, to: 'self.class'

      def self.conditionally_create(event_name)
        first = event_cache[event_name] || by_name(event_name).first
        first ||= create(name: event_name)

        first.tap do |obj|
          event_cache[obj.name] = obj unless event_cache.key?(obj.name)
        end
      end

      def self.by_name(event_name)
        where(name_hash: CityHash.hash64(event_name), name: event_name)
      end

      def before_save
        set_hashes
        super
      end

      def validate
        super
        errors.add(:name, 'cannot be empty') if name.blank?
      end

      def set_hashes  
        self.name_hash = CityHash.hash64 self.name
      end

    end
  end
end