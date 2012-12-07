class ChangeDefaultValuesForFacebookLikesCommentsCount < ActiveRecord::Migration
  def up
    change_column_default(:stories, :fb_likes_count, 0)
    change_column_default(:stories, :fb_comments_count, 0)
    change_column_default(:stories, :external_popularity, 0)
    change_column_default(:stories, :twitter_retweet_count, 0)
  end

  def down
    change_column_default(:stories, :fb_likes_count, nil)
    change_column_default(:stories, :fb_comments_count, nil)
    change_column_default(:stories, :external_popularity, nil)
    change_column_default(:stories, :twitter_retweet_count, nil)
  end
end
