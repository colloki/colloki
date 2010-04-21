class RenameType < ActiveRecord::Migration
  def self.up
    rename_column "stories", "type", "kind"
  end

  def self.down
    rename_column "stories", "kind", "type"
  end
end
