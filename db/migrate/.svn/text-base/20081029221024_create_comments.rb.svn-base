class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.text :body
      t.column(:user_id, :integer, :null => false)      
      t.column(:story_id, :integer, :null => false)      
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
