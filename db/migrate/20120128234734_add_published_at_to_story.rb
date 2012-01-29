class AddPublishedAtToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :published_at, :datetime
  end

  def self.down
    remove_column :stories, :published_at
  end
end
