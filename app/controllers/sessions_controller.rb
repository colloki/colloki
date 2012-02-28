# This controller handles the login / logout function of the site.
class SessionsController < ApplicationController
  # render new.rhtml
  def new
    if logged_in?
      redirect_back_or(root_url)
    elsif request.referer != login_url
      @redir = request.referer
    end
    @new_users = User.newly_activated
    @stories   = Story.latest_with_photos
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token,
          :expires => self.current_user.remember_token_expires_at }
      end
        redirect_to params[:redir],
          :notice => "Welcome back #{self.current_user.login}!"
    else
      redirect_to login_path,
        :alert => "Invalid credentials. Please try again"
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You successfully logged out."
    redirect_back_or(root_url)
  end
end
