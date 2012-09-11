class AddRelatedStoryId < ActiveRecord::Migration
  def self.up
    add_column :stories, :related_story_id, :integer
  end

  def self.down
    remove_column :stories, :related_story_id
  end
end
