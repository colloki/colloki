class AddFacebookLinkField < ActiveRecord::Migration
  def self.up
    add_column :stories, :fb_link, :string
  end

  def self.down
    remove_column :stories, :fb_link
  end
end
