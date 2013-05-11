class AddToRates < ActiveRecord::Migration
  def change
    remove_column :rates, :user_id
    add_column :rates, :session_id, :integer
  end
end
