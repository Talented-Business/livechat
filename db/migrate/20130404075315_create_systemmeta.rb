class CreateSystemmeta < ActiveRecord::Migration
  def change
    create_table :systemmeta do |t|
      t.string :meta_key
      t.string :display_name
      t.string :default
      t.string :meta_value

      t.timestamps
    end
  end
end
