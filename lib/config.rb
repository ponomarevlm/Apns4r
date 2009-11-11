OPTIONS =
  if defined?(RAILS_ENV)
    raw_config = File.read(RAILS_ROOT + "/config/apns4r.yml")
    parsed_config = ERB.new(raw_config).result
    YAML.load(parsed_config)[RAILS_ENV].symbolize_keys
  else
    require 'erb'
    raw_config = File.read(File.expand_path(File.dirname(__FILE__)) + "/../apns4r.yml")
    parsed_config = ERB.new(raw_config).result
    YAML.load(parsed_config).inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
