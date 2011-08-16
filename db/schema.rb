# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090402060133) do

  create_table "activity_items", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.integer  "story_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_id",   :default => -1, :null => false
    t.integer  "kind",       :default => 0,  :null => false
  end

  create_table "comments", :force => true do |t|
    t.text     "body"
    t.integer  "user_id",    :null => false
    t.integer  "story_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stories", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.integer  "views"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     :default => -1, :null => false
    t.integer  "topic_id",    :default => -1, :null => false
    t.integer  "kind",        :default => 0,  :null => false
    t.integer  "popularity",  :default => 0,  :null => false
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     :default => -1, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "realname"
    t.string   "website"
    t.string   "bio"
    t.string   "location"
    t.string   "twitter_id"
    t.string   "delicious_id"
    t.string   "friendfeed_id"
    t.string   "linkedin_url"
    t.string   "facebook_url"
    t.string   "reset_code",                :limit => 40
  end

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id"
    t.string   "voteable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "fk_voteables"
  add_index "votes", ["voter_id", "voter_type"], :name => "fk_voters"

end
