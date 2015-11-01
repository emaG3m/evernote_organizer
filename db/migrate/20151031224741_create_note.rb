class CreateNote < ActiveRecord::Migration
  def up
    create_table :notes do |t|
      t.string   :guid
      t.string   :title
      t.string   :content
      t.integer  :content_length
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :update_sequence_num
    end
  end

  def down
    drop_table :notes
  end
end
