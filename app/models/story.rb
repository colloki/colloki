class Story < ActiveRecord::Base
  # Constant Definitions
  Link = 0
  Post = 1
  Event = 2

  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :kind

  validates_presence_of :url, :if => :is_link?

  validates_format_of :url,
                      :with => /(^$)|(^(http|https):*)/ix,
                      :message => "can only be a valid URL."
  belongs_to :user
  belongs_to :topic
  has_many :comments, :dependent => :destroy
  has_many :activity_items, :dependent => :destroy
  has_many :votes

  has_attached_file :image, :styles => { :thumb => "200x200>" }

  acts_as_taggable

  def is_link?
    kind == Story::Link
  end

  # Regenerate the popularity score
  def update_popularity
    self.popularity = (self.votes.count * 10) + (self.comments.count * 5)
  end

  # Updates the popularity of all Story objects
  def Story.update_popularity_all
    stories = Story.all
    stories.each do |story|
      story.update_popularity
      story.save
    end
  end
end