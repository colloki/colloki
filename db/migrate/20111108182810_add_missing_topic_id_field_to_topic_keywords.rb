class AddMissingTopicIdFieldToTopicKeywords < ActiveRecord::Migration
  def self.up
    add_column :topic_keywords, :topic_id, :integer, :null => false, :default => -1
  end

  def self.down
    remove_column :topic_keywords, :topic_id
  end
end
