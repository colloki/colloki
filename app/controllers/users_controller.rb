class UsersController < ApplicationController
  # render new.rhtml
  def new
    @page_title = "Sign Up"
  end
  
  #TODO: Enhance this or get rid of it.
  def index
    @page_title = "People"
    if not logged_in?
      flash[:alert] = "You need to login to view users."
      #redirect_to "/"
    end
    
    users_unsorted = User.find(:all)
    @users = users_unsorted.sort {|a,b| b.stories.size <=> a.stories.size}    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.mobilesafari
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
    @user = User.find(params[:id])
    @page_title = "Profile for "+ @user.login
    @tags = @user.stories.tag_counts   
    @stories = Story.find(:all, :order => "created_at DESC", :conditions => {:user_id => @user.id}, :limit => 15)
    @comments = Comment.find(:all, :order => "created_at DESC", :conditions => {:user_id => @user.id}, :limit => 7)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @story }
      format.mobilesafari
    end
  end
  
  def settings
    @page_title = "Settings"
    if not logged_in?
      redirect_to root_url
    else
      @user = current_user
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
      flash[:alert] = "That email id is not registered on slurp. Please enter the email id you used to register."
      redirect_to forgot_password_url
    else
      user.make_reset_code
      if user.save
        UserMailer.deliver_reset(user)
        flash[:notice] = "Thank you, we have sent you an email with the reset password link. It should land in your inbox in a few moments. If you don't see it in your inbox for a while, don't forget to check the spam folder."
        redirect_to login_url
      else
        flash[:alert] = "We're sorry, some error occured while trying to generate the reset code. Please contact the site administrator."
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
      flash[:notice] = 'Your password was successfully changed.'
      redirect_to(login_url)
    else
      flash[:alert] = "We couldn't save your new password. Please try again. If the problem persists, please contact the administrator."
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
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up, we've sent you an activation email. 
      \nPlease verify your email by clicking on the activation link in that email."
    else
      render :action => 'new'
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
    

end
