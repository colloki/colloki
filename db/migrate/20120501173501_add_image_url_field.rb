class AddImageUrlField < ActiveRecord::Migration
  def self.up
    add_column :stories, :image_url, :string
  end

  def self.down
    remove_column :stories, :image_url
  end
end
