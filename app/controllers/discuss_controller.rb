class DiscussController < ApplicationController
  def index
    @page_title = "Discussion Dashboard"
    # get the recent activities
    activities = ActivityItem.find :all, :order => "created_at DESC", :include => :comment
    @stories = []
    @story_activities = Hash.new
    for activity in activities
      if activity.kind == ActivityItem::CommentType
        if !@story_activities.has_key?(activity.story_id)
          @story_activities[activity.story_id] = [activity]
          @stories.push(Story.find(activity.story_id))
        else
          @story_activities[activity.story_id].push(activity)
        end
      end
    end
    @comments = Hash.new
    @stories.each do |story|
      @comments[story.id] = []
      story.comments.each do |comment|
        @comments[story.id].push({
          :id => comment.id,
          :body => comment.body,
          :user_login => comment.user.login,
          :user_email_hash => Digest::MD5.hexdigest(comment.user.email),
          :user_id => comment.user.id,
          :timestamp => comment.created_at
        })
      end
    end
    if logged_in?
      @user_id = current_user.id
    else
      @user_id = -1
    end
  end

  def create
  end
end