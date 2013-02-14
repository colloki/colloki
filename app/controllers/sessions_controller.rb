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
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])

    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token,
          :expires => self.current_user.remember_token_expires_at }
      end
        flash[:notice] = "Welcome back #{self.current_user.login}!"
        redirect_to root_url
    else
      flash[:error] = "Incorrect login / password. Please try again"
      redirect_to login_path
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
