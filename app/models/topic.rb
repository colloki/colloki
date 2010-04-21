class Topic < ActiveRecord::Base
  has_many :activity_items
  has_many :stories, :dependent => :destroy    
  belongs_to :user
end
