class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.date :thedate
      t.integer :number
      t.string :status
      t.references :operator

      t.timestamps
    end
    add_index :schedules, :operator_id
  end
end
