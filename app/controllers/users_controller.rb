class UsersController < ApplicationController
  def new
    if logged_in?
      redirect_back_or(root_url)
    else
      @page_title = "Sign Up"
    end
  end

  def index
    @page_title = "People"
    if not logged_in?
      flash[:alert] = "You need to be logged in to view users."
    end

    users_unsorted = User.find(:all)
    @users = users_unsorted.sort {|a,b| b.stories.size <=> a.stories.size}
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def change_password
    @page_title = "Change Password"
    if not logged_in?
      redirect_to root_url
    else
      @user = current_user
    end
  end

  def show
    begin
      @user = User.find(:first, :conditions => {:login => params[:id]})
      @page_title = "Profile for " + @user.login
      @likes_count = Story.count_likes_by_user(@user.id)

      gon.app_url = root_url
      gon.user = @user
      gon.current_user = current_user
      gon.following = (current_user) ? (current_user.following? @user) : false
    rescue
      @page_title = "User not found"
    end

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def settings
    @page_title = "Settings"
    if not logged_in?
      redirect_to root_url
    else
      @user = current_user
      for authentication in @user.provider_authentications
        if authentication[:provider] == "twitter"
          @is_twitter_connected = true
        elsif authentication[:provider] == "facebook"
          @is_facebook_connected = true
        end
      end
    end
  end

  def update
    if not logged_in?
      flash[:alert] = "You need to login to change settings."
      redirect_to :back
    else
      @user = User.find(params[:id])
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Your settings were succesfully updated.'
        redirect_to(settings_url)
      else
        render :action => "settings"
      end
    end
  end

  def forgot_password
    @page_title = "Forgot password"
    if logged_in?
      redirect_to change_password_url
    end
  end

  def send_reset
    if logged_in?
      redirect_to change_password_url
    end

    user = User.find(:first, :conditions => {:email => params[:email]})

    if !user
      flash[:alert] = "That email is not registered on VTS.
        Please enter the email you used to register."
      redirect_to forgot_password_url
    else
      user.make_reset_code
      if user.save
        UserMailer.reset(user).deliver
        flash[:notice] = "Thank you, we have sent you an email with the reset password link.
          It should land in your inbox in a few moments.
          If you don't see it in your inbox for a while, don't forget to check the spam folder."
        redirect_to login_url
      else
        flash[:alert] =
          "We're sorry, an error occured while trying to generate the reset code.
          Please try again later"
      end
    end
  end

  def reset_password
    if logged_in?
      redirect_to change_password
    else
      if(!params[:reset_code] or (params[:reset_code] == ""))
        flash[:alert] = "Could not read any reset code. Please try again."
        redirect_to root_url
      end
      @user = User.find_by_reset_code(params[:reset_code])
      if(!@user)
        flash[:alert] = "That is an invalid reset code. "
        redirect_to root_url
      end
    end
  end

  def update_password_on_reset
    @user = User.find_by_reset_code(params[:current_reset_code])

    if @user.update_attributes(params[:user])
      @user.reset_code = nil
      @user.save
      flash[:notice] = 'Your password was successfully changed. You can now login.'
      redirect_to(login_url)
    else
      flash[:alert] = "We couldn't save your new password.
        Please try again. If the problem persists, please contact the administrator."
      redirect_to root_url
    end
  end

  def create
    cookies.delete :auth_token

    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session

    @user = User.new(params[:user])
    @user.save

    if @user.errors.empty?
      UserMailer.signup_notification(@user).deliver
      flash[:notice] = "Thanks for signing up! We've sent you an activation email.
      \nPlease verify your email by clicking on the activation link in that email."
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false :
      User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default(root_url)
  end

  def whotofollow
    @users = User.newly_activated
    if current_user
      @users.delete(current_user)
    end
    gon.app_url = root_url
    gon.current_user = current_user
    gon.users = @users
    gon.following = []
    for user in @users
      gon.following.push((current_user) ? (current_user.following? user) : false)
    end
  end
end
