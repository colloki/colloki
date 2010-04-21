class ChangeNameFieldInUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :name, :realname
  end

  def self.down
    rename_column :users, :realname, :name
  end
end
