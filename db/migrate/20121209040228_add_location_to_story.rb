class AddLocationToStory < ActiveRecord::Migration
  def change
    add_column :stories, :latitude, :string, :null => true
    add_column :stories, :longitude, :string, :null => true
  end
end
