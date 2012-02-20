require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  TWITTER  = YAML.load_file(Rails.root.join("config/twitter.yml"))[Rails.env]
  FACEBOOK = YAML.load_file(Rails.root.join("config/facebook.yml"))[Rails.env]

  provider :twitter, TWITTER['consumer_key'], TWITTER['consumer_secret']
  provider :facebook, FACEBOOK['app_id'], FACEBOOK['app_secret_key']
end