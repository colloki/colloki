class Story < ActiveRecord::Base
  # Constant Definitions
  Link = 0
  Post = 1
  Rss = 2
  Facebook = 3
  Twitter = 4

  # Facebook Post Types
  FacebookTypeStatus = 0
  FacebookTypeLink = 1
  FacebookTypePhoto = 2

  # Scoring criteria for user contribution in a story
  ScorePost = 10
  ScoreComment = 10
  ScoreShare = 10
  ScoreVote = 5
  ScoreVisit = 1

  # Date Ranges
  DateRangeAll = 1
  DateRangeToday = 2
  DateRangeYesterday = 3
  DateRangeLastWeek = 4

  validates_uniqueness_of :source_url, :if => :is_rss?
  validates_presence_of :url, :if => :is_link?
  validates_format_of :url, :with => /(^$)|(^(http|https):*)/ix, :message => "can only be a valid URL."

  belongs_to :user
  belongs_to :topic

  has_many :comments, :dependent => :destroy
  has_many :activity_items, :dependent => :destroy
  has_many :votes, :dependent => :destroy

  has_attached_file :image,
  :styles => {
    :thumb => "200x150>",
    :medium => "250x250>"
  }

  acts_as_taggable

  # pagination
  self.per_page = 12

  # Checks for the filename "stringio.txt" in addition to an empty string
  # to determine if a story image exists. This can be used across views
  # until we filter out invalid images at the time of saving.
  def image_exists?
    if (image_file_name and
        image_file_name != "" and
        image_file_name != "stringio.txt") or
        image_url and image_url != ''
      return true
    else
      return false
    end
  end

  def image_src(size="thumb")
    if image_exists?
      if image_url
        return image_url
      else
        if size == "medium"
          return image.url(:medium)
        elsif size == "original"
          return image.url(:original)
        else
          return image.url(:thumb)
        end
      end
    else
      return ""
    end
  end

  def is_link?
    kind == Story::Link
  end

  def is_rss?
    kind == Story::Rss
  end

  def is_facebook?
    kind == Story::Facebook
  end

  # increase popularity of story
  def increase_popularity(score)
    self.popularity = self.popularity + score
  end

  # decrease popularity of story
  def decrease_popularity(score)
    self.popularity = self.popularity - score
  end

  def self.add_metadata(stories)
    for story in stories
      story['image_src'] = story.image_src
      if story.user
        story['user_email_hash'] = Digest::MD5.hexdigest(story.user.email)
      end
    end

    return stories
  end

  def self.popular(page)
    stories = page(page).order("popularity DESC, published_at DESC")
    self.add_metadata(stories)
  end

  def self.popular_with_photos
    stories = find :all,
      :conditions => ["image_file_size != ''
        and image_file_name != 'stringio.txt'",
      :order => "popularity DESC",
      :limit => 20]

    self.add_metadata(stories)
  end

  def self.latest(page, should_paginate=true)
    if should_paginate
      stories = page(page).order("published_at DESC")
    else
      stories = find :all, :order => "published_at DESC", :limit => 20
    end

    self.add_metadata(stories)
  end

  def self.latest_with_photos
    stories = find :all,
      :conditions => ["image_file_size != ''
        and image_file_name != 'stringio.txt'",
      :order => "published_at DESC",
      :limit => 20]

    self.add_metadata(stories)
  end

  def self.fb_stories(page, sort)
    if (sort and sort == "likes")
      order = "fb_likes_count DESC"
    elsif (sort and sort == "comments")
      order = "fb_comments_count DESC"
    else
      order = "published_at DESC"
    end

    where(["kind = ?", Story::Facebook])
    .page(page)
    .order(order)
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

  def self.search(params)
    query = params[:query]
    if (query)
      conditions = [ "(title like ? OR description like ? OR source like ? OR source_url like ?)",
        "%#{query}%",
        "%#{query}%",
        "%#{query}%",
        "%#{query}"]
    else
      conditions = []
    end

    if params[:range]
      if params[:range].to_i == Story::DateRangeToday
        start_date = Date.today
        end_date = Date.tomorrow
      elsif params[:range].to_i == Story::DateRangeYesterday
        start_date = Date.yesterday
        end_date = Date.today
      elsif params[:range].to_i == Story::DateRangeLastWeek
        start_date = 1.week.ago
        end_date = Date.today
      end

      if start_date and end_date
        conditions.at(0) << " AND published_at >= ? AND published_at <= ?"
        conditions.push(start_date)
        conditions.push(end_date)
      end
    end

    if params[:topic] and params[:topic].to_i != -2
      conditions.at(0) << " AND topic_id = ?"
      conditions.push(params[:topic])
    end

    stories = paginate(
      :page => params[:page],
      :conditions => conditions,
      :order => "published_at DESC")

    self.add_metadata(stories)
  end

  def self.find_for_topic(topic_id, sort_by, page)
    if sort_by == 'popular'
      order = "popularity DESC, published_at DESC"
    else
      order = "published_at DESC"
    end

    stories = paginate(:page => page,
      :conditions => {:topic_id => topic_id},
      :order => order)
    self.add_metadata(stories)
  end

  def self.find_with_photos_for_topic(topic_id, sort_by)
    if sort_by == 'newest'
      order = "created_at DESC"
    elsif sort_by == 'votes'
      order = "created_at DESC"
    else
      order = "popularity DESC, created_at DESC"
    end

    stories = find :all,
      :order => order,
      :conditions => ["topic_id = ? and
        image_file_size != '' and
        image_file_name != 'stringio.txt' and
        kind = ?", topic_id, Story::Rss],
      :limit => 20
    self.add_metadata(stories)
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
