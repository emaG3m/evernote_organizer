class CreateTagging < ActiveRecord::Migration
  def up
    create_table :taggings, id: :uuid do |t|
      t.uuid :note_id
      t.uuid :tag_id
    end

    add_index :taggings, [:note_id, :tag_id], unique: :true
  end
end
