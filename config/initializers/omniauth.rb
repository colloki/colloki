require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter,  CONFIG['twitter_consumer_key'], CONFIG['twitter_consumer_secret']
  provider :facebook, CONFIG['fb_app_id'], CONFIG['fb_app_secret_key']
end