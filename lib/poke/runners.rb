module Poke
  module Runners

    require 'poke/runners/base'
    require 'poke/runners/mysql'

    def self.runner
      return nil unless Poke.target_db

      case Poke.target_db.adapter_scheme.to_s
      when /^mysql/
        Poke::Runners::Mysql
      end
    end


  end
end