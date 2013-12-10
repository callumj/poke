module Poke
  module Cli
    class Config < Base

      self.visible_name = "config"
      self.description  = "Manages Poke config"

      def run
        sub_action = arg_list[0]
        case sub_action
        when "set"
          perform_set
        when "list"
          perform_list
        else
          error "You must provide a sub-action"
          error "The supported sub-actions are"
          error " * set - Sets a configuration value"
          error " * list - Lists the supported configugration"
        end
      end

      def perform_set
        key = arg_list[1]
        unless key
          error "You must provide a key to set"
          perform_list
          return
        end

        value = arg_list[2..arg_list.length].join(" ")
        unless value
          error "You must specify a value"
          return
        end

        begin
          Poke::Config[key] = value
        rescue Poke::Config::NotPermittedValue => err
          error "Cannot set #{key}"
          error err.message
        end
      end

      def perform_list
        info "You can customise the following configuration keys"
        Poke::Config.manifest.each do |key, info|
          info " * #{key} - #{info["description"]}"
          info "  - Current value: #{Poke::Config[key]}"
        end
      end

    end
  end
end