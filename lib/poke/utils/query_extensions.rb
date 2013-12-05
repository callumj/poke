module Poke
  module Utils
    module QueryExtensions

      def self.included(target)
        target.extend ClassMethods
      end

      module ClassMethods
        def by_hashed_attribute(attribute, value)
          hash_attr = :"#{attribute}_hash"
          where(hash_attr => CityHash.hash64(value), attribute => value)
        end

        def hashed_attributes(*values)
          values.each do |attribute|
            self.class.instance_eval do
              define_method(:"by_#{attribute}") do |value|
                by_hashed_attribute attribute, value
              end
            end
          end
        end
      end

    end
  end
end