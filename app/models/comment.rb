class Comment < ActiveRecord::Base
  validates_presence_of :body

  belongs_to :user
  belongs_to :story
  has_one :activity_item, :dependent => :destroy # todo: why is this not working?

  def self.find_by_user(user_id, limit=5)
    find :all,
    :order => "created_at DESC",
    :conditions => {:user_id => user_id},
    :limit => limit
  end
end
