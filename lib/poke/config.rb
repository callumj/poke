module Poke
  module Config

    def self.[](key)
      SystemModels::Config.cached_hash.try :[], key
    end

  end
end
