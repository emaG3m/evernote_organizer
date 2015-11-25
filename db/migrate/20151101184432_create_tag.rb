class CreateTag < ActiveRecord::Migration
  def up
    create_table :tags, id: :uuid do |t|
      t.string  :name
      t.uuid    :user_id
      t.integer :update_sequence_num
    end
    add_index :tags, [:name, :user_id], unique: :true
  end

  def down
    drop_table :tags
  end
end
