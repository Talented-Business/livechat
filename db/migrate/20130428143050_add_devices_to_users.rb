class AddDevicesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :devicetoken, :string
    add_column :users, :devicetype, :string
  end
end
