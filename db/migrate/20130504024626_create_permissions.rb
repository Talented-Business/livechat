class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.references :operator
      t.boolean :outside_shift
      t.boolean :notes
      t.boolean :order
      t.integer :idle_time
      t.boolean :schedule
      t.date :start_date
      t.date :end_date
      t.boolean :editable_profile_admin
      t.boolean :character_profile_admin
      t.boolean :mass_sending_admin
      t.boolean :kickop_admin
      t.boolean :editable_note_admin

      t.timestamps
    end
  end
end
