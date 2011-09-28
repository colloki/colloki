class AddSourceFieldToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :source, :string
    add_column :stories, :source_url, :string
  end

  def self.down
    remove_column :stories, :source
    remove_column :stories, :source_url
  end
end
