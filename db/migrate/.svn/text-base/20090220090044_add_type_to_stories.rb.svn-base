class AddTypeToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :type, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :stories, :type
  end
end
