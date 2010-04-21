class Story < ActiveRecord::Base

  #Constant Definitions
  Link = 0
  Post = 1
  Event = 2

  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :kind

  validates_presence_of :url, :if => :is_link?
  # CRITICAL TODO: This no longer works with deployment setup of 2.3.2. Not sure if its due to the rails upgrade, or that there is some gem required. 
  #  validates_uri_existence_of :url, :if => :is_link?,:with =>
  #          /(^$)|(^(http|https):*)/ix
          
  validates_format_of :url,
              :with => /(^$)|(^(http|https):*)/ix,
              :message => "can only be a valid URL."
  belongs_to :user
  belongs_to :topic  
  has_many :comments, :dependent => :destroy
  has_many :activity_items, :dependent => :destroy
  
  acts_as_taggable
  acts_as_voteable
  
  def is_link?
    kind == Story::Link
  end
  
  # Regenerate the popularity score. Note: 
  # * The score is an INT. Did not want to introduce floating point calculations for this.
  # * This method DOES NOT save. You need to do that seperately.
  def update_popularity
    self.popularity = (self.votes_for - self.votes_against)*10 + self.comments.count*5
  end

  # Updates the popularity of all Story objects.
  def Story.update_popularity_all
    stories = Story.all
    stories.each do |story|
      story.update_popularity
      story.save
    end
  end

end
