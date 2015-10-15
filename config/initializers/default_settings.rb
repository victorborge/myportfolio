def apply_default_values(value_or_hash, chain)
  if value_or_hash.is_a? RailsConfig::Options
    value_or_hash.each do |k, v|
      apply_default_values(v, "#{chain}.#{k}")
    end
  else
    Setting.defaults[chain.to_sym] = value_or_hash
  end
end

# Load default settings from rails_config yaml files
Config.each do |k, v|
  apply_default_values(v, k)
end