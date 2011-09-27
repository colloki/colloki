class Topic < ActiveRecord::Base
  validates_presence_of :title
  has_many :activity_items
  has_many :stories, :dependent => :destroy
  belongs_to :user
end
