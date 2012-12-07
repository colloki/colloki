class AddTwitterCountToStory < ActiveRecord::Migration
  def change
    add_column :stories, :tweets_count, :integer, :null => false, :default => 0
  end
end
