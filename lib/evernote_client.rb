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

  def user_store
    @user_store ||= client.user_store
  end

  def user_store
    @user_store ||= client.user_store
  end

  def note_store
    @note_store ||= client.note_store
  end

  def notebooks
    @notebooks = note_store.listNotebooks(auth_token)
  end

  def total_note_count
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    counts = note_store.findNoteCounts(auth_token, filter, false)
    notebooks.inject(0) do |total_count, notebook|
      total_count + (counts.notebookCounts[notebook.guid] || 0)
    end
  end
end
