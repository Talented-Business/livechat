class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :name
      t.text :description
      t.attachment :image
      
      t.timestamps
    end
  end
end
