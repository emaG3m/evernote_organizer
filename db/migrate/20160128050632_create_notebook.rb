class CreateNotebook < ActiveRecord::Migration
  def up
    create_table :notebooks, id: :uuid do |t|
      t.string  :name
      t.string  :user_id
      t.integer :update_sequence_num
    end
  end

  def down
    drop_table :notebooks
  end
end
