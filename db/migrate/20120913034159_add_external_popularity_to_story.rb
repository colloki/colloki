class AddExternalPopularityToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :external_popularity, :integer
  end

  def self.down
    remove_column :stories, :external_popularity
  end
end
