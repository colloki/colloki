class VotesController < ApplicationController
  def create
    if logged_in?
      story = Story.find(params[:story_id])
      if !current_user.voted_on?(story)
        @vote = current_user.vote(story)
        story.increase_popularity(Story::ScoreVote)
        story.save
        current_user.activity_items.create(
          :story_id => story.id,
          :topic_id => story.topic_id,
          :vote_id => @vote.id,
          :kind => ActivityItem::VoteType)
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
        vote.story.decrease_popularity(Story::ScoreVote)
        vote.story.save
        current_user.unvote(vote)
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
