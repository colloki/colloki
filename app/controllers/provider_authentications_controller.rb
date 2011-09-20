class ProviderAuthenticationsController < ApplicationController
  # GET /provider_authentications
  # GET /provider_authentications.xml
  def index
    @provider_authentications = ProviderAuthentication.all
  end

  # POST /provider_authentications
  # POST /provider_authentications.xml
  def create
    #todo: Fill in the created_at, activated fields
    omniauth = request.env["omniauth.auth"]
    authentication = ProviderAuthentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    # If the authentication exists, log the user in
    if authentication
      self.current_user = authentication.user
      redirect_to("/", :notice => "Logged in successfully")

    # If the user is already logged in, create a new authentication for the user
    elsif current_user
      current_user.provider_authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      redirect_to("/", :notice => "Logged in successfully")

    # If an account for this user already exists, connect with that account and log the user in
    elsif user = User.find_by_email(omniauth['user_info']['email'])
      user.provider_authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      self.current_user = user
      redirect_to("/", :notice => "Logged in successfully")

    # Create a new user
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        self.current_user = user
        redirect_to("/", :notice => "Logged in successfully")
      else
        # show a page where user can enter login/email
        session[:omniauth] = omniauth.except('extra')
        @login = omniauth['user_info']['nickname']
        @email = omniauth['user_info']['email']
      end
    end
  end

  def complete_signup
    user = User.new
    user.apply_omniauth(session['omniauth'])
    user.login = params[:user]['login']
    user.email = params[:user]['email']
    if user.save!
      self.current_user = user
      redirect_to("/", :notice => "Logged in successfully")
    else
      redirect_to("/")
    end
  end

  # DELETE /provider_authentications/1
  # DELETE /provider_authentications/1.xml
  def destroy
  end
end