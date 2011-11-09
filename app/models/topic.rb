class Topic < ActiveRecord::Base
  validates_presence_of :title
  has_many :activity_items
  has_many :stories, :dependent => :destroy
  has_many :topic_keywords, :dependent => :destroy
  belongs_to :user
end
