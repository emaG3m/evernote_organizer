class CreateUser < ActiveRecord::Migration
  def up
    create_table :users, id: :uuid do |t|
      t.string :username
      t.string :password
      t.string :evernote_username
    end
    add_index :users, :username, unique: true
  end

  def down
    drop_table :users
  end
end
