require 'digest'

module Poke
  module SystemModels
    class Query < Sequel::Model
      
      def before_save
        set_hashes
        super
      end

      def validate
        super
        errors.add(:occurred_at, 'cannot be empty') if occurred_at.blank?
      end

      def set_hashes  
        self.statement_hash  = Digest::SHA256.hexdigest(self.statement)
      end

    end
  end
end
