class AddFavorOpsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :favor_ops, :string
  end
end
