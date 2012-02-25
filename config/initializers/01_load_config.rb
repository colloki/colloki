# config/initializers/load_config.rb
CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]