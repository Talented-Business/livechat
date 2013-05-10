class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :display_name
      t.string :real_name
      t.string :mobile_number
      t.string :status
      t.string :credits
      t.string :sales
      t.string :bonus_credits

      t.timestamps
    end
  end
end
