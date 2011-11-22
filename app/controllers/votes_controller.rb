class VotesController < ApplicationController
  def create
    if logged_in?
      story = Story.find(params[:story_id])
      if !current_user.voted_on?(story)
        @vote = current_user.vote(story)
        story.update_popularity
        story.save
        current_user.activity_items.create(:story_id => story.id, :topic_id => story.topic_id, :kind => ActivityItem::VoteType)
      else
        # todo: send error response
      end
    else
      # todo: send error response
    end
    # todo: send a proper response
    vote = current_user.get_vote(story)
    render :json => {id: vote.id}
  end

  def destroy
    if logged_in?
      vote = Vote.find(params[:id])
      if current_user.voted_on?(vote.story)
        current_user.unvote(vote.story)
        vote.story.update_popularity
        vote.story.save

        activity_item = ActivityItem.find(:first, :conditions => {:user_id => current_user, :story_id => vote.story.id, :kind => ActivityItem::VoteType}, :order => "created_at DESC")
        activity_item.delete
      else
        # todo: send error response
      end
    else
      # todo: send error response
    end
    # todo: send a proper response
    render :json => true
  end
end