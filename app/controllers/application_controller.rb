# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  require File.join(Rails.root, 'lib', 'authenticated_system.rb')
  include AuthenticatedSystem
  include SimpleCaptcha::ControllerHelpers

  helper :all # include all helpers, all the time

  before_filter :get_topics, :save_back_url

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :only => [:create, :update, :destroy] # :secret => '6862e2c9b157c719a7f15caf25016e73'

  @@topic_limit = 5

  private
    def redirect_back_or(path)
      redirect_to :back
      rescue ActionController::RedirectBackError
      redirect_to session[:return_to]
      rescue ActionController::RedirectBackError
      redirect_to path
    end

    def get_topics
      @today_topics = Topic.find(:all, :order => "created_at DESC", :limit => @@topic_limit)
    end

    def save_back_url
      session[:return_to] = request.referer
    end
end
