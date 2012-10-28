class ProviderAuthenticationsController < ApplicationController

  # GET /provider_authentications
  # GET /provider_authentications.xml
  def index
    @provider_authentications = ProviderAuthentication.all
  end

  # POST /provider_authentications
  # POST /provider_authentications.xml
  def create
    omniauth = request.env["omniauth.auth"]
    authentication = ProviderAuthentication.find_by_provider_and_uid(
      omniauth['provider'],
      omniauth['uid'])

    # If the authentication exists, log the user in
    if authentication
      # Update the image URL if it is not already set
      if !authentication.user.image_url
        authentication.user.image_url = omniauth['info']['image'].sub("_normal", "").sub("=square", "=large")
        authentication.user.save
      end

      self.current_user = authentication.user
      redirect_to(root_url, :notice => "Welcome back #{self.current_user.login}!")

    # If the user is already logged in, create a new authentication for the user
    elsif self.current_user
      self.current_user.provider_authentications.create(
        :provider => omniauth['provider'],
        :uid => omniauth['uid'])
      redirect_to(root_url, :notice => "Welcome back #{self.current_user.login}!")

    # If an account for this user already exists, connect with that account and log the user in
    elsif user = User.find_by_email(omniauth['info']['email'])
      user.provider_authentications.create(
        :provider => omniauth['provider'],
        :uid => omniauth['uid'])

      self.current_user = user
      redirect_to(root_url, :notice => "Welcome back #{self.current_user.login}!")

    # Create a new user
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        self.current_user = user
        self.current_user.activate
        redirect_to(root_url, :notice => "Welcome #{self.current_user.login}!")
      else
        # show a page where user can enter login / email
        session[:omniauth] = omniauth.except('extra')
        @login = omniauth['info']['nickname']
        @email = omniauth['info']['email']
      end
    end
  end

  def complete_signup
    @user = User.new
    @user.apply_omniauth(session['omniauth'])
    @user.login = params[:user]['login']
    @user.email = params[:user]['email']
    if @user.save
      self.current_user = @user
      self.current_user.activate
      redirect_to(root_url, :notice => "Welcome #{self.current_user.login}")
    else
      render :action => "create"
    end
  end

  # DELETE /provider_authentications/1
  # DELETE /provider_authentications/1.xml
  def destroy
  end

  def failure
    flash[:notice] = params[:message]
    redirect_back_or root_url
  end
end
