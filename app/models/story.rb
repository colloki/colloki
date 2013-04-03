class Story < ActiveRecord::Base
  # Constant Definitions
  Link = 0
  Post = 1
  Rss = 2
  Facebook = 3
  Twitter = 4
  Likes = 5
  Events = 6
  Following = 7
  ByUser = 8

  # Facebook Post Types
  FacebookTypeStatus = 0
  FacebookTypeLink = 1
  FacebookTypePhoto = 2

  # Scoring criteria
  ScorePost = 10
  ScoreComment = 10
  ScoreShare = 10
  ScoreVote = 5
  ScoreVisit = 1

  ScoreFacebookComment = 2
  ScoreFacebookLike = 1
  ScoreTwitterRetweet = 1

  # Sorting criteria
  SortExternalPopularity = 1
  SortDate = 2

  # Date Ranges
  DateRangeAll = 1
  DateRangeToday = 2
  DateRangeYesterday = 3
  DateRangeLastWeek = 4
  DateRangeLastMonth = 5

  validates_uniqueness_of :source_url, :if => :is_autofetched?
  validates_uniqueness_of :description, :if => :is_rss?
  validates_presence_of :title, :if => :is_post?
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

  profanity_filter! :title, :description, :method => 'stars'

  acts_as_taggable
  acts_as_gmappable :process_geocoding => false

  # pagination
  self.per_page = 12

  attr_accessor :image_src, :user_email_hash
  attr_accessible :image_src, :user_email_hash

  def gmaps4rails_marker_picture
    if kind == Story::Twitter
      picture_name = "twitter"
    elsif kind == Story::Facebook
      puts "************************************"
      puts "Facebook on Map"
      picture_name = "facebook"
    else
      picture_name = "news"
    end

  {
    "picture" => ActionController::Base.helpers.asset_path('map/'+picture_name+'.png'),
    "width" => 21,
    "height" => 43,
    "marker_anchor" => [10, 34],
    "shadow_picture" => ActionController::Base.helpers.asset_path('map/shadow.png'),
    "shadow_width" => 40,
    "shadow_height" => 37,
    "shadow_anchor" => [12, 35]
  }
end

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

  # Returns the image url for the story
  def get_image_url(size="thumb")
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

  def is_autofetched?
    is_rss? or is_facebook? or is_twitter?
  end

  # Returns true if the story is of link type
  def is_link?
    kind == Story::Link
  end

  # Returns true if the story was fetched from an RSS feed
  def is_rss?
    kind == Story::Rss
  end

  # Returns true if the story is fetched from Facebook
  def is_facebook?
    kind == Story::Facebook
  end

  def is_twitter?
    kind == Story::Twitter
  end

  def is_post?
    kind == Story::Post
  end

  # Increase the popularity of the story by the specified score
  def increase_popularity(score)
    self.popularity = self.popularity + score
  end

  # Decrease the popularity of the story by the specified score
  def decrease_popularity(score)
    self.popularity = self.popularity - score
  end

  # Get all the related stories to the current story
  def related_posts
    Story.find(:all, :conditions => { :related_story_id => self.id })
  end

  # Add image_src and user_email_hash fields to the stories' objects
  def self.add_metadata(stories)
    for story in stories
      story.image_src = story.get_image_url

      if story.user
        story.user_email_hash = Digest::MD5.hexdigest(story.user.email)
      end
    end

    return stories
  end

  # Get the stories for the RSS feed (excluding Twitter and Facebook posts)
  def self.latest_for_rss
    find :all,
      :conditions => ["kind != ? and kind != ?", Story::Facebook, Story::Twitter],
      :order => "published_at DESC",
      :limit => 20
  end

  def self.search_stories(params)
    if params[:topic_id]
      conditions = {
        :kind => Story::Rss,
        :topic_id => params[:topic_id]
      }
    else
      conditions = {
        :kind => Story::Rss
      }
    end

    stories = Story.paginate(
      :page => params[:page],
      :limit => params[:limit].to_i,
      :order => "created_at DESC",
      :conditions => conditions);
    self.add_metadata(stories)
  end

  def self.search_twitter(params)
    stories = Story.paginate(
      :page => params[:page],
      :limit => params[:limit].to_i,
      :order => "created_at DESC",
      :conditions => {
        :kind => Story::Twitter,
        :related_story_id => params[:related_story_id]
      });
  end

  def self.search_facebook(params)
    stories = Story.paginate(
      :page => params[:page],
      :limit => params[:limit].to_i,
      :order => "created_at DESC",
      :conditions => {
        :kind => Story::Facebook,
        :related_story_id => params[:related_story_id]
      });
  end

  # TODO(ankit): Each of these should be a separate API, instead of munging
  # everything together into a single method.
  def self.search(params)
    # Following
    if params[:type].to_i == Story::Following
      user = User.find(params[:user_id])
      following = user.all_following
      user_ids = []

      for user in following
        user_ids.push(user.id)
      end

      likes = Vote.paginate(
        :page => params[:page],
        :order => "created_at DESC",
        :conditions => ["user_id IN (?)", user_ids]
      )

      stories = []
      for like in likes
        if !stories.index(like.story)
          stories.push(like.story)
        end
      end

    # Likes
    elsif params[:type].to_i == Story::Likes
      likes = Vote.paginate(
        :page => params[:page],
        :order => "created_at DESC",
        :conditions => {:user_id => params[:user_id]}
      );

      stories = []
      for like in likes
        stories.push(like.story)
      end

    # User Shared Posts
    elsif params[:type].to_i == Story::Post
      stories = Story.paginate(
        :page => params[:page],
        :order => "created_at DESC",
        :conditions => {:kind => Story::Post});

    # Posts by a specific user
    elsif params[:type].to_i == Story::ByUser
      stories = Story.paginate(
        :page => params[:page],
        :order => "created_at DESC",
        :conditions => {:user_id => params[:user_id]});

    else
      # Search
      query = params[:query]
      if query and query != ""
        conditions = [ "(title like ? OR description like ?)",
          "%#{query}%",
          "%#{query}%"
        ]
      # Source
      elsif params[:source] and params[:source].to_i != -1
        conditions = ["(source like ?)", "#{params[:source]}"]
      # Topic
      elsif params[:topic] and params[:topic].to_i != -2
        conditions = ["(topic_id = ?)", params[:topic]]
      else
        conditions = []
      end

      if params[:hashtag] and params[:hashtag] != "" and params[:type].to_i == Story::Twitter
        condition = "(lower(title) like ?)"
        if conditions.at(0)
          conditions.at(0) << " AND " << condition
        else
          conditions.push(condition)
        end
        conditions.push("%\##{params[:hashtag]}%");
      end

      # Date Range
      if params[:range]
        if params[:range].to_i == Story::DateRangeToday
          start_date = Date.today
          end_date = Date.tomorrow
        elsif params[:range].to_i == Story::DateRangeYesterday
          start_date = Date.yesterday
          end_date = Date.today
        elsif params[:range].to_i == Story::DateRangeLastWeek
          start_date = 1.week.ago
          end_date = Date.tomorrow
        end

        if start_date and end_date
          condition = "published_at >= ? AND published_at <= ?"
          if conditions.at(0)
            conditions.at(0) << " AND " << condition
          else
            conditions.push(condition)
          end
          conditions.push(start_date)
          conditions.push(end_date)
        end
      end

      # Type
      if params[:type]
        kinds = params[:type].split(",")

        if conditions.at(0)
          conditions.at(0) << " AND ("
        else
          conditions.push("(")
        end

        kinds.each_with_index{|kind, index|
          conditions.at(0) << "kind = ?"
          if (index < kinds.count - 1)
            conditions.at(0) << " OR "
          end
          conditions.push(kind)
        }

        conditions.at(0) << ")"
      end

      # Sorting
      if params[:sort] and params[:sort].to_i == Story::SortExternalPopularity
        order = "external_popularity DESC, published_at DESC"
      else
        order = "published_at DESC"
      end

      stories = paginate(
        :page => params[:page],
        :conditions => conditions,
        :order => order)
    end

    self.add_metadata(stories)
  end

  # Get all the stories written by the specified user
  def self.find_by_user(user_id, limit=10)
    find :all, :order => "created_at DESC",
         :conditions => {:user_id => user_id},
         :limit => limit
  end

  # Get the number of likes by user
  # TODO(ankit): This belongs in the User Model
  def self.count_likes_by_user(user_id)
    likes = Vote.find :all,
      :conditions => {:user_id => user_id}
    return likes.count
  end

  # Find a story by the source url
  def self.find_by_url(url)
    find :first, :conditions=>{:source_url => url}
  end

  # Get the popular hashtags for twitter posts in the last week
  def self.hashtags
    hashtag_regex = /(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i
    # Get all the tweets this week
    tweets = find :all, :conditions => ["published_at >= ? AND published_at <= ? AND kind = ?",
      Date.today, Date.tomorrow, Story::Twitter]

    hashtags_map = Hash.new

    for tweet in tweets
      hashtags = tweet.title.scan(hashtag_regex)
      for hashtag in hashtags
        hashtag = hashtag[0].downcase

        if hashtags_map.has_key?(hashtag)
          hashtags_map[hashtag] = hashtags_map[hashtag] + 1
        else
          hashtags_map[hashtag] = 1
        end
      end
    end
    # put all the hashtags into an array
    sorted_hashtags = []

    hashtags_map.map do |key, value|
      sorted_hashtags << {:name => key, :count => value}
    end

    sorted_hashtags.sort_by{ |hashtag| -hashtag[:count]}[0..19]
  end

end
