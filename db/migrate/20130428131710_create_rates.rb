class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.references  :operator
      t.references  :user
      t.decimal     :skill
      t.decimal     :communication
      t.decimal     :friendliness
      t.decimal     :recommend
      t.timestamps
    end
  end
end
