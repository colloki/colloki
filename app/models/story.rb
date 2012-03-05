class Story < ActiveRecord::Base
  # Constant Definitions
  Link  = 0
  Post  = 1
  Rss   = 2

  # Scoring criteria:
  #
  # User Post: 30
  # Comment: 20
  # Share on Twitter, Facebook, Google+, Email: 10
  # Like:    5
  # Visit:   1
  #
  ScorePost       = 30
  ScoreComment    = 20
  ScoreShare      = 10
  ScoreVote       = 5
  ScoreVisit      = 1

  validates_presence_of   :title
  validates_presence_of   :description
  validates_presence_of   :kind
  validates_uniqueness_of :source_url,  :if => :is_rss?
  validates_presence_of   :url,         :if => :is_link?
  validates_format_of     :url,
                          :with => /(^$)|(^(http|https):*)/ix,
                          :message => "can only be a valid URL."
  belongs_to :user
  belongs_to :topic

  has_many :comments,       :dependent => :destroy
  has_many :activity_items, :dependent => :destroy
  has_many :votes,          :dependent => :destroy

  has_attached_file :image, :styles => { 
    :thumb => "200x150>", 
    :medium => "250x250>" }

  acts_as_taggable

  # pagination
  self.per_page = 9

  def is_link?
    kind == Story::Link
  end

  def is_rss?
    kind == Story::Rss
  end

  # increase popularity of story
  def increase_popularity(score)
    self.popularity = self.popularity + score
  end

  # decrease popularity of story
  def decrease_popularity(score)
    self.popularity = self.popularity - score
  end

  def self.popular(page)
    require 'will_paginate/array'
    popular = find :all,
                   :order => "published_at DESC",
                   :limit => 50
    popular.sort! { |a, b| b.popularity <=> a.popularity }
    popular.paginate(:page => page, :per_page => 9)
  end

  def self.popular_with_photos
    self.latest_with_photos.sort! { |a, b| b.popularity <=> a.popularity }
  end

  def self.latest(page, should_paginate=true)
    if should_paginate
      page(page).order("published_at DESC")
    else
      find :all, :order => "published_at DESC", :limit => 20
    end
  end

  def self.latest_with_photos
    find :all,
         :conditions => ["image_file_size != '' and image_file_name !='stringio.txt'"],
         :order => "published_at DESC", 
         :limit => 20
  end

  def self.active
    # get the recent activities
    activities = ActivityItem.find :all,
                                   :conditions => ["kind = ? or kind = ?", 
                                     ActivityItem::CommentType, 
                                     ActivityItem::CreatePostType],
                                   :order => "updated_at DESC"
    stories = []
    story_activities = Hash.new
    for activity in activities
      if activity.kind == ActivityItem::CommentType or 
          activity.kind == ActivityItem::CreatePostType
        if !story_activities.has_key?(activity.story_id)
          story_activities[activity.story_id] = [activity]
          stories.push(Story.find(activity.story_id))
        else
          story_activities[activity.story_id].push(activity)
        end
      end
    end
    return stories
  end

  def self.search(query, page)
    paginate(:page => page,
      :conditions => [ "title like ? OR description like ? OR source like ? OR source_url like ?",
        "%#{query}%",
        "%#{query}%",
        "%#{query}%",
        "%#{query}"],
      :order => "published_at DESC")
  end

  def self.find_for_topic(topic_id, sort_by, page)
    if sort_by == 'popular'
      order = "popularity DESC, created_at DESC"
    else
      order = "created_at DESC"
    end

    paginate(:page => page,
      :conditions => {:topic_id => topic_id},
      :order => order)
  end

  def self.find_with_photos_for_topic(topic_id, sort_by)
    if sort_by == 'newest'
        order = "created_at DESC"
    elsif sort_by == 'votes'
      order = "created_at DESC"
    else
      order = "popularity DESC, created_at DESC"
    end
    find :all,
         :order => order,
         :conditions => ["topic_id = ? and
           image_file_size != '' and
           image_file_name != 'stringio.txt' and
           kind = ?", topic_id, Story::Rss],
         :limit => 20
  end

  def self.find_by_user(user_id, limit=10)
    find :all,
         :order => "created_at DESC",
         :conditions => {:user_id => user_id},
         :limit => limit
  end

  def self.find_liked_by_user(user_id, limit=10)
    likes = Vote.find :all,
                      :order => "created_at DESC",
                      :conditions => {:user_id => user_id},
                      :limit => limit
    stories = []
    for like in likes
      stories.push(like.story)
    end
    stories
  end
end