class CreateUser < ActiveRecord::Migration
  def up
    create_table :users, id: :uuid do |t|
      t.string :email
      t.string :password_hash
      t.string :evernote_username
    end
    add_index :users, :email, unique: true
  end

  def down
    drop_table :users
  end
end
