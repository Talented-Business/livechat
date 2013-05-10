class AddAttachmentDisplayAvatarToOperators < ActiveRecord::Migration
  def self.up
    change_table :operators do |t|
      t.attachment :display_avatar
    end
  end

  def self.down
    drop_attached_file :operators, :display_avatar
  end
end
