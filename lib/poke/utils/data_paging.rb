module Poke
  module Utils
    class DataPaging

      def self.mass_select(scope, primary_key = nil)
        base_scope = scope.limit(10_000)

        if primary_key
          base_scope = base_scope.order(Sequel.asc(primary_key))
        end

        results = []
        previous_results = base_scope.to_a

        size = previous_results.count
        while previous_results.any?
          if block_given?
            res = yield previous_results
            return if res == false
          else
            results.concat previous_results
          end
          
          break if results.length < 10_000
          if primary_key
            max_pk = previous_results.map { |obj| obj.send(primary_key) }.max

            previous_results = base_scope.where("#{primary_key} > ?", max_pk).to_a
          else
            previous_results = base_scope.limit(10_000, size).to_a
            size += previous_results.count
          end
        end
        results
      end

    end
  end
end