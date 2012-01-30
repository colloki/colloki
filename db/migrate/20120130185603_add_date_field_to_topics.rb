class AddDateFieldToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :day, :datetime
  end

  def self.down
    remove_column :topics, :day
  end
end
