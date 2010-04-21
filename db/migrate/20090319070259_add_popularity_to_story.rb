class AddPopularityToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :popularity, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :stories, :popularity
  end
end
