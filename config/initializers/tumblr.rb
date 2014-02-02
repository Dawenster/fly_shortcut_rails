Tumblr.configure do |config|
  config.consumer_key = ENV['TUMBLR_CONSUMER_KEY']
  config.consumer_secret = ENV['TUMBLR_SECRET_KEY']
  config.oauth_token = ENV['TUMBLR_ACCESS_TOKEN']
  config.oauth_token_secret = ENV['TUMBLR_ACCESS_TOKEN_SECRET']
end