class NotifierController < ApplicationController
  def send_blog_suggestion
    if simple_captcha_valid?
      UserMailer.blog_suggestion(params[:blog]).deliver
      flash[:notice] = "We received the link, thank you! We'll try to add your suggestion soon."
    else
      flash[:error] = "You got the CAPTCHA wrong! Please try again"
    end
    redirect_back_or root_url
  end
end
