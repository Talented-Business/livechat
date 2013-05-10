class AddChatHistoryToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :chat_history, :text
  end
end
