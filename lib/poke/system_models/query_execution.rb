module Poke
  module SystemModels
    class QueryExecution < Sequel::Model
      many_to_one :query, class: "Poke::SystemModels::Query"
    end
  end
end