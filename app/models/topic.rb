class Topic < ActiveRecord::Base
  validates_presence_of :title

  has_many :stories, :dependent => :destroy
  has_many :topic_keywords, :dependent => :destroy
  has_many :activity_items, :dependent => :destroy

  belongs_to :user

  def self.all_sorted_by_day
    find :all,
    :order => "day DESC"
  end
end
