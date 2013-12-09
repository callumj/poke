module Poke
  module Cli

    require 'poke/cli/base'
    require 'poke/cli/run'
    require 'poke/cli/report'
    require 'poke/cli/db'
    require 'poke/cli/console'

    def self.invoke(name, arg_list)
      inst = Poke::Cli::Base.available_implementations[name].new(arg_list)
      res = inst.run

      if res.is_a?(String)
        STDOUT.puts res
      end
    end

  end
end