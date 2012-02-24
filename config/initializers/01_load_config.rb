# config/initializers/load_config.rb
CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml")[RAILS_ENV]