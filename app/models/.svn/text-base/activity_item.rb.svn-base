class ActivityItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :story
  belongs_to :topic

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
      "commented on "
    elsif self.kind == UpdateType
      "updated "
    elsif self.kind == VoteType
      "voted for "
    elsif self.kind == UnVoteType
      "un-voted "
    elsif self.kind == CreateLinkType
      "posted link "
    elsif self.kind == CreatePostType
      "posted opinion "
    elsif self.kind == NullType
      " "
    end
  end
  
end
