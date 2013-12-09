module Poke
  module Cli
    class Db < Base

      class_attribute :visible_name
      self.visible_name = "db"

      def run
        case arg_list[0]
        when "init"
          Poke::Utils::DbManagement.init_system_db(options[:recreate] == "true")
        end
      end

    end
  end
end