class TopicsController < ApplicationController
  # GET /topics
  # GET /topics.xml
  def popular
    require 'will_paginate/array'
    @page_title = "Most Popular"
    # todo: find a more optimized way (via sql query) to get the top recent posts
    @stories = Story.find(:all, :order => "created_at DESC", :limit => 50)
    @stories.sort! { |a, b| b.popularity <=> a.popularity }
    @stories = @stories.paginate(:page => params[:page], :per_page => 10)
    @activity_items = ActivityItem.all(:order => "created_at DESC", :limit => 5)
    @new_users = User.find(:all, :conditions => "activated_at IS NOT NULL", :order => "created_at DESC")
    @tags = Story.tag_counts_on(:tags)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stories }
    end
  end

  def search
    @query = params[:query]
    @page_title = "Search results for #{@query}"
    @stories = Story.find :all, :conditions =>  [ "title like ? OR description like ? ", "%#{@query}%", "%#{@query}%"]
    @activity_items = ActivityItem.all(:order => "created_at DESC", :limit => 5)
    @new_users = User.find(:all, :conditions => "activated_at IS NOT NULL", :order => "created_at DESC")
    @tags = Story.tag_counts_on(:tags)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stories }
    end
  end

  def latest
    @page_title = "Latest"
    @stories = Story.paginate(:page => params[:page]).order("created_at DESC")
    @activity_items = ActivityItem.all(:order => "created_at DESC", :limit => 5)
    @new_users = User.find(:all, :conditions => "activated_at IS NOT NULL", :order => "created_at DESC")
    @tags = Story.tag_counts_on(:tags)
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic = Topic.find(params[:id])

    if params[:sort] == 'newest'
      sort_order = "created_at DESC"
    elsif params[:sort] == 'votes'
      sort_order = "created_at DESC"
    else
      sort_order = "popularity DESC, created_at DESC"
      params[:sort] = 'popular'
    end

    if params[:tab] == 'links'
      query = {:topic_id => @topic.id, :kind => Story::Link}
    elsif params[:tab] == 'posts'
      query = {:topic_id => @topic.id, :kind => Story::Post}
    else
      query = {:topic_id => @topic.id}
      params[:tab] = 'all'
    end

    @stories = Story.paginate(:conditions => query, :order => sort_order, :page => params[:page])

    # TODO: This is not contextual. It shows the tag cloud for the topic, not the stories currently being displayed.
    # @stories.tag_counts doesn't work, apparently the method is not defined for @stories, meaning @stories is a different object
    # from @topic.stories
    @tags = @topic.stories.tag_counts
    @activity_items = ActivityItem.find(:all, :conditions => "topic_id = #{@topic.id}", :order => "created_at DESC", :limit => 10)
    #@activity_items = ActivityItem.find(:all, :order => "created_at DESC", :limit => 10)

    @top_users = User.top_in_topic(@topic.id)

    if params[:tab] != 'all'
      @page_title = @topic.title + " " + params[:tab]
    else
      @page_title = @topic.title
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stories }
      # format.mobilesafari
    end
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    if logged_in?
      @topic = Topic.new
      @page_title = "Create a new topic"
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @topic }
      end
    else
      flash[:alert] = "You need to be logged in to add a new topic"
      redirect_to :back
    end
  end

  # GET /topics/1/edit
  def edit
    if logged_in?
      @topic = Topic.find(params[:id])
    else
      flash[:alert] = "You need to be logged in to add a new topic"
      redirect_to :back
    end
  end

  # POST /topics
  # POST /topics.xml
  def create
    @topic = Topic.new(params[:topic])
    if logged_in?
       @topic.user_id = current_user.id
       if @topic.save
         flash[:notice] = 'Topic was successfully created.'
         redirect_to(@topic)
       else
         render :action => "new"
       end
    else
       flash[:alert] = "You need to login to create a new topic."
       render :action => "new"
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:notice] = 'Topic was successfully updated.'
        format.html { redirect_to(@topic) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(topics_url) }
      format.xml  { head :ok }
    end
  end

  def tag
    tag_list = params[:tag_list].split('+')
    @tag = tag_list.join(' + ')
    if params[:id]
      @topic = Topic.find(params[:id])
      @stories = @topic.stories.tagged_with(tag_list, :match_all => true)
      @tags = @topic.stories.tag_counts
      @page_title = @topic.title + " posts and links tagged with " + @tag
    else
      @stories = Story.tagged_with(tag_list, :any => true)
      @tags = Story.tag_counts
      @page_title = "Everything tagged with " + @tag
    end
  end

end