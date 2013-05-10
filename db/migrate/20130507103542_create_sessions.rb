class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.datetime :start
      t.datetime :end
      t.references :user
      t.references :operator
      t.timestamps
    end
    change_table :chat_messages do |t|
      t.references :session
    end
  end
end
