class RemoveRedundantUserAttributes < ActiveRecord::Migration
  def self.up
    remove_column :users, :twitter_id
    remove_column :users, :linkedin_url
    remove_column :users, :facebook_url
  end

  def self.down
    add_column :users, :twitter_id, :string, :null => true
    add_column :users, :linkedin_url, :string, :null => true
    add_column :users, :facebook_url, :string, :null => true
  end
end
