class RemoveThumbsUp < ActiveRecord::Migration
  def self.up
    remove_column :votes, :vote
    remove_column :votes, :voteable_type
    remove_column :votes, :voter_type
    rename_column :votes, :voteable_id, :story_id
    rename_column :votes, :voter_id, :user_id
  end

  def self.down
    add_column :votes, :vote, :boolean, :default => false
    add_column :votes, :voteable_type, :string
    add_column :votes, :voter_type, :string
    rename_column :votes, :story_id, :voteable_id
    rename_column :votes, :user_id, :voter_id
  end
end
