class AddAdminUserToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :recipient_id, :integer
    add_column :topics, :sender_id, :integer
  end
end
