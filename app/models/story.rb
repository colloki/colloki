class Story < ActiveRecord::Base
  # Constant Definitions
  Link = 0
  Post = 1
  Rss = 2

  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :kind

  # prevent duplicate stories
  validates_uniqueness_of :source_url

  validates_presence_of :url, :if => :is_link?

  validates_format_of :url,
                      :with => /(^$)|(^(http|https):*)/ix,
                      :message => "can only be a valid URL."
  belongs_to :user
  belongs_to :topic
  has_many :comments, :dependent => :destroy
  has_many :activity_items, :dependent => :destroy
  has_many :votes

  has_attached_file :image, :styles => { :thumb => "200x150>", :medium => "250x250>" }

  acts_as_taggable

  # pagination
  self.per_page = 9

  def is_link?
    kind == Story::Link
  end

  # Regenerate the popularity score
  def update_popularity
    self.popularity = (self.votes.count * 10) + (self.comments.count * 5)
  end

  # update popularity for all stories
  def self.update_popularity_all
    stories = Story.all
    stories.each do |story|
      story.update_popularity
      story.save
    end
  end

  def self.popular(page)
    require 'will_paginate/array'
    popular = find :all, :order => "created_at DESC", :limit => 50
    popular.sort! { |a, b| b.popularity <=> a.popularity }
    popular.paginate(:page => page, :per_page => 9)
  end

  def self.latest(page)
    page(page).order("created_at DESC")
  end

  def self.search(query, page)
    paginate(:page => page,
    :conditions => [ "title like ? OR description like ? ", "%#{query}%", "%#{query}%"])
  end

  def self.find_for_topic(topic_id, sort_by, page)
    if sort_by == 'newest'
      order = "created_at DESC"
    elsif sort_by == 'votes'
      order = "created_at DESC"
    else
      order = "popularity DESC, created_at DESC"
    end
    paginate(:page => page,
    :conditions => {:topic_id => topic_id},
    :order => order)
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