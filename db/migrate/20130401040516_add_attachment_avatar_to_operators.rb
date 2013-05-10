class AddAttachmentAvatarToOperators < ActiveRecord::Migration
  def self.up
    change_table :operators do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :operators, :avatar
  end
end
