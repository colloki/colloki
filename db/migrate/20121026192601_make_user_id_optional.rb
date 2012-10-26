class MakeUserIdOptional < ActiveRecord::Migration
  def up
    change_column :stories, :user_id, :integer, :null => true
    change_column_default(:stories, :user_id, nil)
  end

  def down
    change_column :stories, :user_id, :integer, :null => false
    change_column_default(:stories, :user_id, -1)
  end
end
