class AddToLanguagesOperators < ActiveRecord::Migration
  def change
    change_table :operators do |t|
      t.string :languages
    end
  end
end
