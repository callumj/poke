require 'cityhash'

module Poke
  module SystemModels
    class ExecutionEvent < Sequel::Model

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