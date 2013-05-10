class AddColumesToUser < ActiveRecord::Migration
  def change
    add_column :users, :country, :string
    add_column :users, :short_bio, :string
    add_column :users, :long_bio, :string
  end
end
