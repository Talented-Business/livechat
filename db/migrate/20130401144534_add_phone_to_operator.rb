class AddPhoneToOperator < ActiveRecord::Migration
  def change
    change_table :operators do |t|
      t.boolean :block, :default => false
      t.string :mobile_number
      t.string :real_name
    end
  end
end
