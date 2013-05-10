class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :note
      t.boolean :viewable, :default=>true
      t.references :operator
      t.references :user

      t.timestamps
    end
  end
end
