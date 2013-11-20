require 'cityhash'

module Poke
  module SystemModels
    class Query < Sequel::Model

      def self.conditionally_create(obj_hash)
        existing = where(statement_hash: CityHash.hash64(obj_hash[:statement])).first

        if existing && existing.schema == obj_hash[:schema] && existing.statement == obj_hash[:statement]
          return existing
        else
          create obj_hash
        end
      end

      def self.most_recent_statements
        max     = Poke::SystemModels::Query.max :occurred_at
        queries = Poke::SystemModels::Query.where(occurred_at: max).select(:statement).to_a

        return Time.parse(max), queries.map(&:statement)
      end
      
      def before_save
        set_hashes
        super
      end

      def validate
        super
        errors.add(:occurred_at, 'cannot be empty') if occurred_at.blank?
        errors.add(:statement,   'cannot be empty') if statement.blank?
      end

      def set_hashes  
        self.statement_hash = CityHash.hash64 self.statement
      end

    end
  end
end
