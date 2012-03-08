class ActivityItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :story
  belongs_to :topic

  belongs_to :comment
  belongs_to :vote

  # Constant Definitions
  # Note: DO NOT change the numeric values. If you do, reset the database, because the bindings would be all wrong.
  # Ideally, just create a new type with a new number, and add its representation to the sentence definition below.
  NullType          = 0
  CommentType       = 1
  UpdateType        = 2
  VoteType          = 3
  UnVoteType        = 4
  CreateLinkType    = 5
  CreatePostType    = 6

  def sentence
    if self.kind == CommentType
      "commented "
    elsif self.kind == UpdateType
      "updated "
    elsif self.kind == VoteType
      "liked "
    elsif self.kind == UnVoteType
      "unliked "
    elsif self.kind == CreateLinkType
      "posted link "
    elsif self.kind == CreatePostType
      "posted "
    elsif self.kind == NullType
      " "
    end
  end

  def self.recent(limit=10)
    all(:order => "created_at DESC", :limit => limit)
  end

  def self.find_for_topic(topic_id, limit=5)
    find(:all, :conditions => "topic_id = #{topic_id}", :order => "created_at DESC", :limit => limit)
  end
end
