require 'singleton'

class EvernoteClient
  include Singleton

  def self.client
    @client ||= EvernoteClient.new.client
  end

  def initialize
  end
end
