class EvernoteAccountSyncer

  attr_reader :evernote_client, :user_id, :notebook_ids

  def initialize(evernote_client, user_id, notebook_ids)
    @evernote_client = evernote_client
    @user_id = user_id
    @notebook_ids = notebook_ids
  end

  def sync_account
    sync_notebooks
    sync_tags
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

  def sync_tags
    evernote_client.tags.each do |tag|
      guid = tag.guid
      if !Tag.exists?(guid)
        Tag.create!(
          id: tag.guid,
          name: tag.name,
          user_id: user_id,
          update_sequence_num: tag.updateSequenceNum
        )
      end
    end
  end

  def sync_notes
    evernote_client.note_guids.each do |note_guid|
      note    = evernote_client.fetch_note(note_guid)
      content = note.content.gsub( %r{</?[^>]+?>}, '' )
      if !Note.exists?(note_guid)
        Note.create!(
          id: note_guid,
          title: note.title,
          content: content,
          created_at: Time.at(note.created/1000),
          updated_at: Time.at(note.updated/1000),
          update_sequence_num: note.updateSequenceNum
        )
      end
      create_taggings_for_note(note_guid, note.tagGuids)
    end
  end

  def create_taggings_for_note(note_guid, tag_guids)
    tag_guids.try(:each) do |tag_guid|
      Tagging.create!(
        note_id: note_guid,
        tag_id: tag_guid
      )
    end
  rescue ActiveRecord::RecordNotUnique
  end
end
