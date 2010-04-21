class AddResetCodeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :reset_code, :string, :limit => 40
  end

  def self.down
    remove_column :users, :reset_code
  end
end
