["config", "query"].each do |model_name|
  require "poke/system_models/#{model_name}"
end
