class AddAttachmentAvatarToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :devise, :avatar
  end
end
