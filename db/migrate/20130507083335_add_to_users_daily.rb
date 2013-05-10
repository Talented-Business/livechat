class AddToUsersDaily < ActiveRecord::Migration
  def change
    add_column :users, :daily_message, :boolean, :default => false    
  end
end
