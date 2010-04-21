class ReplaceSentenceWithKind < ActiveRecord::Migration
  def self.up
    add_column :activity_items, :kind, :integer, :null => false, :default => 0
    remove_column :activity_items, :sentence
  end

  def self.down
    remove_column :activity_items, :kind
    add_column :activity_items, :sentence, :string, :null => false
  end
end
