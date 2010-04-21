# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :only => [:create, :update, :destroy] # :secret => '6862e2c9b157c719a7f15caf25016e73'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password

  private
    def redirect_back_or(path)
      redirect_to :back
      rescue ActionController::RedirectBackError
      redirect_to path
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
