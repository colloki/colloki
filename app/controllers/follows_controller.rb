class FollowsController < ApplicationController
  def create
    if logged_in?
      user = User.find params[:user_id]
      if !current_user.following? user
        current_user.follow(user)
        current_user.save
      end
    else
      # todo: send error response
    end
    # todo: send back proper response
    render :json => true
  end

  def unfollow
    if logged_in?
      user = User.find params[:user_id]
      current_user.stop_following(user)
      current_user.save
    else
      # todo: send error response
    end
    # todo: send a proper response
    render :json => true
  end
end
