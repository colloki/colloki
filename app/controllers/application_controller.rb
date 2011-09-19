# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  require File.join(Rails.root, 'lib', 'authenticated_system.rb')
  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  before_filter :get_topics

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :only => [:create, :update, :destroy] # :secret => '6862e2c9b157c719a7f15caf25016e73'

  private
    def redirect_back_or(path)
      redirect_to :back
      rescue ActionController::RedirectBackError
      redirect_to path
    end

    def get_topics
      @topics = Topic.all
    end

  # Removing iPhone specific views for the time being

  #   before_filter :set_mobilesafari_format
  #
  # private
  #   def set_mobilesafari_format
  #     if request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]
  #       request.format = :mobilesafari
  #     end
  #   end
end
