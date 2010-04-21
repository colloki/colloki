class AddTopicRelationships < ActiveRecord::Migration
  def self.up
    add_column :stories, :topic_id, :integer, :null => false, :default => -1
    add_column :activity_items, :topic_id, :integer, :null => false, :default => -1    
    add_column :topics, :user_id, :integer, :null => false, :default => -1
  end

  def self.down
    remove_column :stories, :topic_id
    remove_column :activity_items, :topic_id    
    remove_column :topics, :user_id
  end
end