class DiscussController < ApplicationController
  def index
    @page_title = "Discussion Dashboard"
    @activities = ActivityItem.find :all, :order => "created_at DESC", :include => :comment
  end

  def create
  end
end