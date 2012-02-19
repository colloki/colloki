require 'will_paginate/array'

class DiscussController < ApplicationController
  def index
    @page_title = "Discuss"

    # get the recent activities
    activities = ActivityItem.find :all, :order => "created_at DESC", :include => :comment

    @stories = []
    @story_activities = Hash.new
    for activity in activities
      if activity.kind == ActivityItem::CommentType or activity.kind == ActivityItem::CreatePostType
        if !@story_activities.has_key?(activity.story_id)
          @story_activities[activity.story_id] = [activity]
          @stories.push(Story.find(activity.story_id))
        else
          @story_activities[activity.story_id].push(activity)
        end
      end
    end

    @comments = Hash.new

    @stories.each do |story|
      @comments[story.id] = []
      story.comments.each do |comment|
        @comments[story.id].push({
          :id               => comment.id,
          :body             => comment.body,
          :user_login       => comment.user.login,
          :user_email_hash  => Digest::MD5.hexdigest(comment.user.email),
          :user_id          => comment.user.id,
          :timestamp        => comment.created_at
        })
      end
    end

    if @stories.count != 0
      @stories = @stories.paginate(:page => params[:page], :per_page => 5)
    end

    if logged_in?
      @user_id = current_user.id
    else
      @user_id = -1
    end
  end

  def create
    if logged_in?
      # save story
      story = Story.new
      story.kind = Story::Post
      story.description = params[:discuss][:description].to_s
      story.title = params[:discuss][:title].to_s
      story.topic_id = params[:discuss][:topic].to_i
      if params[:discuss][:photo]
        story.image = params[:discuss][:photo]
      end
      story.user_id = current_user.id
      story.source_url = ""
      story.published_at = DateTime.now
      if story.save
        flash[:notice] = "Your story '" << story.title << "' was successfully posted!"
        # create activity
        activity = ActivityItem.create(
          :story_id => story.id,
          :user_id  => current_user.id,
          :topic_id => params[:discuss][:topic].to_i,
          :kind     => ActivityItem::CreatePostType)
        activity.save
      end
    else
      flash[:alert] = 'You need to be logged in to post a story!'
    end
    redirect_back_or_default(discuss_url)
  end
end