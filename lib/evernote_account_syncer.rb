class EvernoteAccountSyncer

  attr_reader :evernote_client, :user_id, :notebook_ids, :auth_token

  def initialize(auth_token, evernote_client, user_id, notebook_ids)
    @auth_token = auth_token
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
      #SyncNotesWorker.new.perform(auth_token, note_guid)
      SyncNotesWorker.perform_async(auth_token, note_guid)
    end
  end
end
