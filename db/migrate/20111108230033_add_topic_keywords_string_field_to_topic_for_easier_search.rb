class AddTopicKeywordsStringFieldToTopicForEasierSearch < ActiveRecord::Migration
  def self.up
    add_column :topics, :keywords, :string
  end

  def self.down
    remove_column :topics, :keywords
  end
end
