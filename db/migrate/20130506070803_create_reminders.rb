class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.string :name
      t.integer :inactivity
      t.integer :setting_time
      t.integer :spread
      t.string :message

      t.timestamps
    end
  end
end
