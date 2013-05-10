class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message
      t.references :topic
      t.timestamps
    end
    add_index :messages, :topic_id
  end
end
