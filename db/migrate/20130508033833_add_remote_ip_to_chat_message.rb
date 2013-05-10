class AddRemoteIpToChatMessage < ActiveRecord::Migration
  def change
    add_column :chat_messages, :remote_ip, :string
  end
end
