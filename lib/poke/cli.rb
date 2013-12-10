module Poke
  module Cli

    require 'poke/cli/base'
    require 'poke/cli/run'
    require 'poke/cli/report'
    require 'poke/cli/db'
    require 'poke/cli/console'
    require 'poke/cli/help'
    require 'poke/cli/config'

    def self.invoke(name, arg_list)
      klass = Poke::Cli::Base.available_implementations[name]
      unless klass
        invoke "help", []
        return false
      end

      inst = klass.new(arg_list)
      res = inst.run

      if res.is_a?(String)
        STDOUT.puts res
      end
    end

  end
end