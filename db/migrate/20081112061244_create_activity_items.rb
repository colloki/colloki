class CreateActivityItems < ActiveRecord::Migration
  def self.up
    create_table :activity_items do |t|
      t.integer :user_id, :null=>false
      t.integer :story_id, :null=>false
      t.string :sentence, :null=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :activity_items
  end
end
