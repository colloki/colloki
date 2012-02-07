class TopicsController < ApplicationController
  # GET /topics
  # GET /topics.xml
  def popular
    @page_title = "Most Popular"
    @stories = Story.popular(params[:page])
    @stories_with_photos = Story.popular_with_photos
    @new_users = User.newly_activated
    @activity_items = ActivityItem.recent
    @tags = Story.tag_counts_on(:tags)
    respond_to do |format|
      format.html
    end
  end

  def latest
    @page_title = "Latest"
    @stories = Story.latest(params[:page])
    # todo: eliminate this duplicate, unhealthy request
    @stories_with_photos = Story.latest_with_photos
    @new_users = User.newly_activated
    @activity_items = ActivityItem.recent
    @tags = Story.tag_counts_on(:tags)
    respond_to do |format|
      format.html
    end
  end

  def search
    @query = params[:query]
    @page_title = "Search results for '#{params[:query]}'"
    @stories = Story.search(params[:query], params[:page])
    @new_users = User.newly_activated
    @activity_items = ActivityItem.recent
    @tags = Story.tag_counts_on(:tags)
    respond_to do |format|
      format.html
    end
  end

  def archive
    @page_title = "Archive"
    @all_topics = Topic.all_sorted_by_day
    respond_to do |format|
      format.html
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic = Topic.find(params[:id])
    @stories = Story.find_for_topic(@topic.id, params[:sort], params[:page])
    @stories_with_photos = Story.find_with_photos_for_topic(@topic.id, params[:sort])
    @tags = @topic.stories.tag_counts
    @activity_items = ActivityItem.find_for_topic(@topic.id)
    @top_users = User.top_in_topic(@topic.id)
    @page_title = @topic.title

    respond_to do |format|
      format.html
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