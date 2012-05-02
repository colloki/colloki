class AddFacebookIdField < ActiveRecord::Migration
  def self.up
    add_column :stories, :fb_id, :string
  end

  def self.down
    add_column :stories, :fb_id
  end
end
