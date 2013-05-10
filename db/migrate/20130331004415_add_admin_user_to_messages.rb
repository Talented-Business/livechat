class AddAdminUserToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :recipient_id, :integer, :references=>"operators"
    add_column :messages, :sender_id, :integer, :references=>"operators"
  end
end
