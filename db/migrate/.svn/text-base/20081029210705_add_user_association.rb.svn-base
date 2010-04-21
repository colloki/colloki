class AddUserAssociation < ActiveRecord::Migration
  def self.up
    add_column :stories, :user_id, :integer, :null => false, :default => -1
  end

  def self.down
    remove_column :stories, :user_id
  end
end
