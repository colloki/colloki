class CommentsController < ApplicationController
  def create
    if logged_in?
      comment = Comment.create(:body => params[:body].to_s, :user_id => current_user.id, :story_id => params[:story_id].to_i)
      comment.save

      # update story popularity
      story = Story.find(params[:story_id])
      story.update_popularity
      story.save

      # update user activity stream
      current_user.activity_items.create(:story_id => story.id, :topic_id => story.topic_id, :kind => ActivityItem::CommentType)

      @comment = {
        :id => comment.id,
        :body => comment.body,
        :user_login => current_user.login,
        :user_email_hash => Digest::MD5.hexdigest(current_user.email),
        :user_id => current_user.id,
        :timestamp => comment.created_at
      }

    else
      #TODO: send back error response
    end

    render :json => @comment
  end

  def destroy
    if logged_in?
      @comment = Comment.find(params["id"])
      if (@comment.user_id == current_user.id)
        @comment.delete

        #TODO: This is not ideal. Need to delete the exact related activity item,
        #that can only be done if the activity_item model is completely re-thought. Later.
        activity_item = ActivityItem.find :first,
        :conditions => {:user_id => @comment.user_id,
          :story_id => @comment.story.id,
          :kind => ActivityItem::CommentType },
          :order => "created_at DESC"
        activity_item.delete
      end

      render :json => ""
    end
  end
end