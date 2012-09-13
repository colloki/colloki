class AddFieldsForTwitterStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :twitter_id, :string
    add_column :stories, :twitter_retweet_count, :integer
  end

  def self.down
    remove_column :stories, :twitter_id
    remove_column :stories, :twitter_retweet_count
  end
end
