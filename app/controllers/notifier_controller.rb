class NotifierController < ApplicationController
  def send_blog_suggestion
    UserMailer.blog_suggestion(params[:blog]).deliver
    flash[:notice] = "We received the link, thank you! We'll try to add your suggestion soon."
    redirect_back_or root_url
  end
end
