module Poke
  module Config

    def self.[](key)
      SystemModels::Config.cached_hash.try :[], key
    end

    def self.[]=(key, value)
      existing = SystemModels::Config.find(key: key)
      existing ||= SystemModels::Config.new.tap do |c|
        c.key = key
      end
      existing.value = value
      existing.save

      SystemModels::Config.cached_hash[key] = value
      value
    end

  end
end
