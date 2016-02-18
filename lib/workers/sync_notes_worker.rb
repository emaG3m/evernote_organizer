require_relative '../evernote_client.rb'
require_relative '../../models/note.rb'
require_relative '../../models/tagging.rb'

class SyncNotesWorker
  include Sidekiq::Worker

  def perform(auth_token, note_guid)
    note = EvernoteClient.new(auth_token).fetch_note(note_guid)
    if !Note.exists?(note_guid)
      content = note.content.gsub( %r{</?[^>]+?>}, '' )
      Note.create!(
        id: note_guid,
        title: note.title,
        content: content,
        updated_at: Time.at(note.created/1000),
        created_at: Time.at(note.created/1000),
        update_sequence_num: note.updateSequenceNum
      )
    end
    create_taggings_for_note(note_guid, note.tagGuids)
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
