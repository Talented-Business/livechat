class AddUnreadToMessage < ActiveRecord::Migration
  def change
    change_table(:messages) do |t|
      ## Database authenticatable
      t.boolean :unread, :default => true

    end
    
  end
end
