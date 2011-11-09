class CreateTopicKeywords < ActiveRecord::Migration
  def self.up
    create_table :topic_keywords do |t|
      t.string :name
      t.decimal :distribution

      t.timestamps
    end
  end

  def self.down
    drop_table :topic_keywords
  end
end
