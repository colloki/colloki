class RemoveDeliciousAndFriendFeed < ActiveRecord::Migration
  def self.up
    remove_column :users, :delicious_id
    remove_column :users, :friendfeed_id
  end

  def self.down
    add_column :users, :delicious_id, :string, :null => true
    add_column :users, :friendfeed_id, :string, :null => true
  end
end
