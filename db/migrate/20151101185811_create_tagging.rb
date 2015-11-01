class CreateTagging < ActiveRecord::Migration
  def up
    create_table :taggings, id: :uuid do |t|
      t.string :note_id
      t.string :tag_id
    end
  end
end
