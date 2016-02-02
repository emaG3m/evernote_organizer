class EvernoteAccountSyncer

  attr_reader :evernote_client, :notebook_ids

  def initialize(evernote_client, notebook_ids)
    @evernote_client = evernote_client
    @notebook_ids = notebook_ids
  end

  def sync_account
    sync_notebooks
    sync_notes
  end

  private

  def sync_notebooks
    evernote_client.notebooks.each do |notebook|
      guid = notebook.guid
      if notebook_ids.include?(guid) && !Notebook.find_by_id(guid)
        Notebook.create!(
          id: notebook.guid,
          name: notebook.name,
          update_sequence_num: notebook.updateSequenceNum
        )
      end
    end
  end

  def sync_notes
    evernote_client.note_guids.each do |note_guid|
      note    = evernote_client.fetch_note(note_guid)
      content = note.content.gsub( %r{</?[^>]+?>}, '' )
      if !Note.find_by_id(note_guid)
        Note.create!(
          id: note_guid,
          title: note.title,
          content: content,
          created_at: Time.at(note.created/1000),
          updated_at: Time.at(note.updated/1000),
          update_sequence_num: note.updateSequenceNum
        )
      end
    end
  end
end
