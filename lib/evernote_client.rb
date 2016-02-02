class EvernoteClient

  attr_reader :client, :auth_token

  def initialize(auth_token)
    @auth_token = auth_token
    @client = EvernoteOAuth::Client.new(
      token: auth_token,
      consumer_key: OAUTH_CONSUMER_KEY,
      consumer_secret:OAUTH_CONSUMER_SECRET,
      sandbox: SANDBOX
    )
  end

  def user_store
    @user_store ||= client.user_store
  end

  def user
    @user ||= user_store.getUser(auth_token)
  end

  def note_store
    @note_store ||= client.note_store
  end

  def notebooks
    @notebooks = note_store.listNotebooks(auth_token)
  end

  def note_guids
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    spec = Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new()
    @note_guids ||= note_store.findNotesMetadata(auth_token, filter, 0, 5000, spec).notes.map(&:guid)
  end

  def fetch_note(note_guid)
    note_store.getNote(auth_token, note_guid, true, false, false, false)
  end
end
