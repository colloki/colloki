class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :story
  has_one :activity_item, :dependent => :destroy
end