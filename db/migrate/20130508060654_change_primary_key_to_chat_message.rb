class ChangePrimaryKeyToChatMessage < ActiveRecord::Migration
  def change
    drop_table :chat_messages
    create_table :chat_messages, :id => false,:primary_key => "prihash" do |t|
      t.string   "prihash"
      t.integer  "operator_id"
      t.integer  "user_id"
      t.string   "message"
      t.boolean  "direction"
      t.integer  "session_id"
      t.string   "remote_ip"
      t.timestamps
    end
  end  
end
