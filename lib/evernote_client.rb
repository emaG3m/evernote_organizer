require 'singleton'
require 'pry'

class EvernoteClient
  include Singleton

  def client(auth_token = nil)
    @client ||= EvernoteOAuth::Client.new(
      token: auth_token,
      consumer_key: OAUTH_CONSUMER_KEY,
      consumer_secret:OAUTH_CONSUMER_SECRET,
      sandbox: SANDBOX
    )
  end
end
