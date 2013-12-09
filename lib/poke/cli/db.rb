module Poke
  module Cli
    class Db < Base

      class_attribute :visible_name
      self.visible_name = "db"

      def run
        case arg_list[0]
        when "init"
          info "Preparing database"
          Poke::Utils::DbManagement.init_system_db(options[:recreate] == "true")
        else
          error "You must provide a operation"
          error " * init - Creates the database and tables. Set recreate:true to force a rebuild"
        end
      end

    end
  end
end