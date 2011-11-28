class UpdateActivityItem < ActiveRecord::Migration
  def self.up
    add_column :activity_items, :comment_id, :integer, :default => -1
    add_column :activity_items, :vote_id, :integer, :default => -1
  end

  def self.down
    remove_column :activity_items, :comment_id
    remove_column :activity_items, :vote_id
  end
end
