class AddEmailToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.boolean :block, :default => false
      t.string :email
    end
  end
end
