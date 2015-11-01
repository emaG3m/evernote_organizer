class CreateTag < ActiveRecord::Migration
  def up
    create_table :tags, id: :uuid do |t|
      t.string  :name
      t.integer :update_sequence_num
    end
  end

  def down
    drop_table :tags
  end
end
