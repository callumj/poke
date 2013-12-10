module Poke
  module Config

    class Error < StandardError; end
    class NotPermittedValue < Error; end

    def self.manifest
      @manifest ||= YAML.load_file File.join(APP_PATH, "lib", "poke", "data", "config_manifest.yml")
    end

    def self.[](key)
      v = SystemModels::Config.cached_hash.try :[], key
      coerce key, v
    end

    def self.[]=(key, value)
      info = manifest[key]
      if info && (supported_values = info["options"]).present?
        raise NotPermittedValue, "Supported values are #{supported_values.join(",")}" unless supported_values.include?(value)
      end

      existing = SystemModels::Config.find(key: key)
      existing ||= SystemModels::Config.new.tap do |c|
        c.key = key
      end
      existing.value = value
      existing.save

      SystemModels::Config.cached_hash[key] = value
    end

    def self.coerce(key, value)
      info = manifest[key]

      return unless info

      if value
        case info["type"]
        when "Fixnum"
          value.to_i
        when "Boolean"
          ["1", "true"].include?(value)
        else
          value.to_s
        end
      else
        info["default"]
      end
    end

  end
end
