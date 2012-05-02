class AddFacebookStoryFields < ActiveRecord::Migration
  def self.up
    add_column :stories, :fb_type, :integer
    add_column :stories, :fb_likes_count, :integer
    add_column :stories, :fb_comments_count, :integer
  end

  def self.down
    remove_column :stories, :fb_type
    remove_column :stories, :fb_likes_count
    remove_column :stories, :fb_comments_count
  end
end
