class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
      t.references :operator
      t.references :user
      t.string :message
      t.boolean :direction
      t.timestamps
    end
    change_table :operators do |t|
      t.datetime :session_update
    end
    change_table :users do |t|
      t.datetime :session_update
    end
  end
end
