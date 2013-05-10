class CreateOperators < ActiveRecord::Migration
  def change
    create_table :operators do |t|
      t.string :name
      t.string :display_name
      t.string :country
      t.string :short_bio
      t.string :long_bio

      t.timestamps
    end
  end
end
