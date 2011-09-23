class StoriesController < ApplicationController

  # Added this for implementing search functionality which currently only exists in Mobile Safari apps
  # -MM Nov 25, 2008
  def search
    @stories = Story.find :all, :conditions =>  [ "title like ? OR description like ? ", "%#{params[:query]}%", "%#{params[:query]}%"]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stories }
      # format.mobilesafari { render :layout => false }
    end
  end

  def rss
    #TODO: Need to move this whole action onto the topic controller.
    stories_unsorted = Story.find(:all)
    if params[:id] == 'votes'
      @stories = stories_unsorted.sort{|a,b| b.votes  <=> a.votes }
      @title = "Slurp! Most Voted Stories"
      @description = "Most voted  stories on the slurp link sharing site"
    elsif params[:id] == 'newest'
      @title = "Slurp! Latest Stories"
      @description = "Newest stories on the slurp link sharing site"
      @stories = stories_unsorted.sort{|a,b| b.created_at <=> a.created_at}
    elsif (params[:id] == 'tag') && (params[:id2])
      @title = "Slurp! Stories tagged " + params[:id2]
      @description = "Stories on slurp tagged with " + params[:id2]
      tag_list = params[:id2].split('+')
      stories_unsorted = Story.find_tagged_with(tag_list, :match_all => true)
      @stories = stories_unsorted.sort{|a,b| b.created_at <=> a.created_at}
    else
      # default sort by popular
      @stories = stories_unsorted.sort{|a,b| (b.views/10) + b.votes + b.comments.count <=> (a.views/10) + a.votes + a.comments.count}
      @title = "Slurp! Popular Stories"
      @description = "Popular stories on the slurp link sharing site"
    end
    render :layout => false
    headers["Content-Type"] = "application/xml"
  end

  # TODO: The URL for this action is currently http://site/stories/<ID>. It needs to be http://site/topic/<Topic_ID>/story/<ID>
  # or if topics get mnemonics, then, http://site/<topic-mnemonic>/{links|posts}/<ID>
  def show
    @story = Story.find(params[:id])
    if (!@story)
      redirect_to root_url
    end

    @topic = Topic.find(@story.topic_id)
    @page_title = @story.title
    if @story.views == nil
      @story.views = 1
    else
      @story.views = @story.views + 1
    end
    @story.update_popularity
    @story.save
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @story }
      # format.mobilesafari { render :layout => false }
    end
  end

  # GET /stories/new
  def new
    if not logged_in?
      flash[:alert] = "You need to login to create stories."
      redirect_to topical_url(:id => params[:topic_id])
    else
      @topic = Topic.find(params[:topic_id])
      @story = @topic.stories.build
      @page_title = "Add a " + params[:kind] + " to " + @topic.title
      if (params[:kind]=="link")
        @story.kind = Story::Link
        if params[:url]
          @story.url = params[:url]
        end
        if params[:title]
          @story.title = params[:title]
        end
        if params[:desc]
          @story.description = params[:desc]
        end
      elsif (params[:kind]=="post")
        @story.kind = Story::Post
      elsif (params[:kind]=="event")
        @story.kind = Story::Event
      end
      respond_to do |format|
        format.html # new.html.erb
      end
    end
  end

  # GET /stories/1/edit
  def edit
    if not logged_in?
      flash[:alert] = "You need to login to edit stories."
      redirect_to :back
    elsif not current_user.id == Story.find(params[:id]).user.id
      flash[:alert] = "You need to be the author of the story to edit it."
      redirect_to :back
    else
      @story = Story.find(params[:id])
      @page_title = "Edit " + @story.title
    end
  end

  # POST /stories
  # POST /stories.xml
  def create
    @topic = Topic.find(params[:topic_id])
    @story = @topic.stories.build(params[:story])
    # Check for img tags to store images.
    # todo: this is just for testing at the moment.
    require 'nokogiri'
    require 'open-uri'
    doc = Nokogiri::HTML(params[:story]['description'])
    img_tag = doc.search('img').first
    if img_tag
      #store it as an attachment
      src = img_tag['src']
      @story.image = open(URI.parse(src))
    end

    @story.views = 0
    if logged_in?
      @story.user_id = current_user.id
      @story.update_popularity
      if @story.save
        if @story.is_link?
          current_user.activity_items.create(:story_id => @story.id, :topic_id => @topic.id, :kind => ActivityItem::CreateLinkType)
        else
          current_user.activity_items.create(:story_id => @story.id, :topic_id => @topic.id, :kind => ActivityItem::CreatePostType)
        end

        if params[:redirect]
          redirect_to(params[:redirect])
        else
          flash[:notice] = 'Story was successfully created.'
          redirect_to(@story)
        end
      else
        flash[:alert] = 'Story could not be saved.'
        logger.debug "[DEBUG] Story couldn't be saved, errors: " + @story.errors.to_s
        render :action => 'new'
      end
    else
      flash[:alert] = "You need to login to create stories."
      logger.debug "[DEBUG] User didn't log on before trying to create a story."
      render :action => 'new'
    end
  end

  # PUT /stories/1
  # PUT /stories/1.xml
  def update
    if not logged_in?
      flash[:alert] = "You need to login to edit stories."
      redirect_to :back
    elsif not current_user.id == Story.find(params[:id]).user.id
      flash[:alert] = "You need to be the author of the story to edit it."
      redirect_to :back
    else
      @story = Story.find(params[:id])
      @story.update_popularity
      respond_to do |format|
        if @story.update_attributes(params[:story])
          flash[:notice] = 'Story was successfully updated.'
          format.html { redirect_to(@story) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /stories/1
  # DELETE /stories/1.xml
  def destroy
    if not logged_in?
      flash[:alert] = "You need to login to edit stories."
      redirect_to :back
    elsif not current_user.id == Story.find(params[:id]).user.id
      flash[:alert] = "You need to be the author of the story to edit it."
      redirect_to :back
    else
      @story = Story.find(params[:id])
      @topic = @story.topic
      @story.destroy
      redirect_to @topic
    end
  end

  def comment
    if logged_in?
      @story = Story.find(params["id"])
      @story.comments.create(:body => params[:comment][:body].to_s, :user_id => current_user.id)
      current_user.activity_items.create(:story_id => @story.id, :topic_id => @story.topic_id, :kind => ActivityItem::CommentType)

      #Update the story's popularity
      @story.update_popularity
      @story.save

      flash[:notice] = "Successfully created your comment."
    else
      flash[:alert] = "You cannot comment without logging in, so quit trying!"
    end
    redirect_to :action=>"show", :id => params[:id]
  end


  def delete_comment
    if logged_in?
      @story = Story.find(params["id"])
      @comment = Comment.find(params["cid"])
      if (@comment.user_id == current_user.id)
        @comment.delete

        #TODO: This is not ideal. Need to delete the exact related activity item, that can only be done if the activity_item model is completely re-thought. Later.
        activity_item = ActivityItem.find(:first, :conditions => {:user_id => @comment.user_id, :story_id => @story.id, :kind => ActivityItem::CommentType }, :order => "created_at DESC")
        activity_item.delete
      end
      redirect_to :back
    end
  end

  #TODO: Make it ajaxy
  def vote
    if logged_in?
      story = Story.find(params[:id])
      if !current_user.voted_on?(story)
        current_user.vote(story)
        story.update_popularity
        story.save
        current_user.activity_items.create(:story_id => story.id, :topic_id => story.topic_id, :kind => ActivityItem::VoteType)
      else
        flash[:alert] = "You cannot like multiple times, so quit trying!"
      end
    else
      flash[:alert] = "You cannot like without logging in, so quit trying!"
    end
    redirect_to :back
  end

  #TODO: Make it ajaxy
  def unvote
    if logged_in?
      story = Story.find(params[:id])
      if current_user.voted_on?(story)
        current_user.unvote(story)
        story.update_popularity
        story.save

        activity_item = ActivityItem.find(:first, :conditions => {:user_id => current_user, :story_id => story.id, :kind => ActivityItem::VoteType}, :order => "created_at DESC")
        activity_item.delete
      else
        flash[:alert] = "You cannot dislike multiple times."
      end
    else
      flash[:alert] = "You cannot dislike without logging in."
    end
    redirect_to :back
  end

  def feed_interface
    @error_msg = params[:error_msg]
  end
end