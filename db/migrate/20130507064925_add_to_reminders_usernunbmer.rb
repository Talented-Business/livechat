class AddToRemindersUsernunbmer < ActiveRecord::Migration
  def change
    add_column :reminders, :not_users, :integer, :default => 0    
  end

end
