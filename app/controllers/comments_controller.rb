class CommentsController < ApplicationController
  def create
    if logged_in?
      comment = Comment.create(
        :body     => params[:body].to_s,
        :user_id  => current_user.id,
        :story_id => params[:story_id].to_i)
      comment.save

      # increment story popularity
      story = Story.find(params[:story_id])
      story.increase_popularity(Story::ScoreComment)
      story.save

      # create activity
      activity = ActivityItem.create(
        :story_id   => story.id,
        :user_id    => current_user.id,
        :topic_id   => story.topic_id,
        :comment_id => comment.id,
        :kind       => ActivityItem::CommentType)

      @comment = {
        :id               => comment.id,
        :body             => comment.body,
        :user_login       => current_user.login,
        :user_email_hash  => Digest::MD5.hexdigest(current_user.email),
        :user_id          => current_user.id,
        :timestamp        => comment.created_at
      }

    else
      # todo: send back error response
    end

    render :json => @comment
  end

  def destroy
    if logged_in?
      comment = Comment.find params["id"]
      if comment.user == current_user
        comment.story.decrease_popularity(Story::ScoreComment)
        comment.story.save
        comment.activity_item.delete
        comment.delete
      end
      render :json => ""
    end
  end
end