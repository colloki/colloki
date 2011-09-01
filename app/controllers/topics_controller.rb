class TopicsController < ApplicationController
  # GET /topics
  # GET /topics.xml
  def index
    @page_title = "Home"
    @topics = Topic.find(:all, :include => :stories)
    @topics.sort! { |a,b| b.stories.count <=> a.stories.count }
    @activity_items = ActivityItem.all(:order =>"created_at DESC", :limit => 10)
    @new_users = User.find(:all, :conditions => "activated_at IS NOT NULL", :order => "created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic = Topic.find(params[:id])

    if params[:sort] == 'newest'
      sort_order = "created_at DESC"
      sort_title = "date"
    elsif params[:sort] == 'votes'
      #CRITICAL TODO: The "Votes" tab is not working right now
      #to resolve it, first need to get rid of the plugin-based voting.
      sort_order = "created_at DESC"
    else
      sort_order = "popularity DESC, created_at DESC"
      sort_title = "popularity"
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
    
    @stories = Story.paginate(:conditions => query, :order => sort_order, :page => params[:page], :per_page => 10)
    
    # TODO: This is not contextual. It shows the tag cloud for the topic, not the stories currently being displayed. 
    # @stories.tag_counts doesn't work, apparently the method is not defined for @stories, meaning @stories is a different object 
    # from @topic.stories
    @tags = @topic.stories.tag_counts
    @activity_items = ActivityItem.find(:all, :conditions => "topic_id = #{@topic.id}", :order => "created_at DESC", :limit => 10)
    #@activity_items = ActivityItem.find(:all, :order => "created_at DESC", :limit => 10)

    # top_users_unsorted = @topic.stories.users
    # @top_users = top_users_unsorted.sort {|a,b| b.stories.count + b.comments.count <=> a.stories.count + a.comments.count}
    # @top_users = @top_users[0..4]

    @top_users = User.top_in_topic(@topic.id)

    if params[:tab] != 'all'
      @page_title = @topic.title + " " + params[:tab] + " sorted by " + sort_title
    else
      @page_title = @topic.title + " " + " sorted by " + sort_title
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
      @stories = @topic.stories.find_tagged_with(tag_list, :match_all => true)
      @tags = @topic.stories.tag_counts
      @page_title = @topic.title + " posts and links tagged with " + @tag     
    else
      @stories = Story.find_tagged_with(tag_list, :match_all => true)
      @tags = Story.tag_counts            
      @page_title = "Everything tagged with " + @tag           
    end
  end
  
end