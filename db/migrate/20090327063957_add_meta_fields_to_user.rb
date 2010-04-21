class AddMetaFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string, :null => true
    add_column :users, :website, :string, :null => true
    add_column :users, :bio, :string, :null => true
    add_column :users, :location, :string, :null => true                
    add_column :users, :twitter_id, :string, :null => true
    add_column :users, :delicious_id, :string, :null => true
    add_column :users, :friendfeed_id, :string, :null => true
    add_column :users, :linkedin_url, :string, :null => true
    add_column :users, :facebook_url, :string, :null => true        
  end

  def self.down
    remove_column :users, :name
    remove_column :users, :website
    remove_column :users, :bio
    remove_column :users, :location
    remove_column :users, :twitter_id
    remove_column :users, :delicious_id
    remove_column :users, :friendfeed_id
    remove_column :users, :linkedin_url
    remove_column :users, :facebook_url
  end
end
