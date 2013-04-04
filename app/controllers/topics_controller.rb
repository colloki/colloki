class TopicsController < ApplicationController
  before_filter :get_topics

  def get_topics
    @today_topics = Topic.find(:all, :order => "created_at DESC", :limit => @@topic_limit)
  end

  def index
    gon.app_url = root_url
    gon.current_user = current_user
    @hashtags = Story.hashtags
    config = YAML.load_file("#{Rails.root}/config/sources.yml")[Rails.env]
    @news_sources = config['rss'].values.sort
    @facebook_sources = config['facebook'].sort

    @maps = [].to_gmaps4rails

    respond_to do |format|
      format.html
    end
  end

  def map
    conditions = []

    if params[:type]
      if params[:type] == Story::Rss.to_s
        condition = "(kind = " << Story::Rss.to_s << ")"
      elsif params[:type] == "3,4"
        condition = "(kind = " << Story::Twitter.to_s << " OR kind = " << Story::Facebook.to_s << ")"
      else
        condition = "(kind = " << Story::Twitter.to_s << " OR kind = " << Story::Rss.to_s << ")"
      end
    end

    conditions.push(condition)

    # Date Range
    if params[:range]
      if params[:range].to_i == Story::DateRangeLastWeek
        start_date = 1.week.ago
        end_date = Date.tomorrow
      elsif params[:range].to_i == Story::DateRangeLastMonth
        start_date = 1.month.ago
        end_date = Date.tomorrow
      end

      if start_date and end_date
        conditions.at(0) << " AND " << "published_at >= ? AND published_at <= ?"
        conditions.push(start_date)
        conditions.push(end_date)
      end
    end

    stories = Story.find(:all,
      :conditions => conditions,
      :order => "created_at DESC")

    @map = stories.to_gmaps4rails do |story, marker|
      marker.title story.title
      marker.infowindow render_to_string(:partial => "/topics/map_tooltip", :formats => [:html], :locals => {:story => story})
      marker.json({ :id => story.id, :title => story.title, :user => story.user})
    end

    respond_to do |format|
      format.json { render :json => @map }
    end
  end

  def search
    gon.app_url = root_url
    gon.current_user = current_user
    @stories = Story.search(params)
    respond_to do |format|
      format.json { render :json => @stories, :include => [:votes, :comments, :user],
        :methods => [:user, :image_src, :tweets_count, :user_email_hash]}
    end
  end

  def search_stories
    @stories = Story.search_stories(params)
    respond_to do |format|
      format.json { render :json => @stories, :include => [:votes, :comments, :user],
        :methods => [:user, :image_src, :tweets_count, :user_email_hash]}
    end
  end

  def search_twitter
    @stories = Story.search_twitter(params)
    respond_to do |format|
      format.json { render :json => @stories, :include => [:votes, :comments, :user],
        :methods => [:user, :image_src, :tweets_count, :user_email_hash]}
    end
  end

  def search_facebook
    @stories = Story.search_facebook(params)
    respond_to do |format|
      format.json { render :json => @stories, :include => [:votes, :comments, :user],
        :methods => [:user, :image_src, :tweets_count, :user_email_hash]}
    end
  end

  def search_topic
    @topic = Topic.find(params[:id])
    respond_to do |format|
      format.json {
        render :json => @topic
      }
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
      @topic      = Topic.find(params[:id])
      @stories    = @topic.stories.tagged_with(tag_list, :match_all => true)
      @tags       = @topic.stories.tag_counts
      @page_title = @topic.title + " posts and links tagged with " + @tag
    else
      @stories    = Story.tagged_with(tag_list, :any => true)
      @tags       = Story.tag_counts
      @page_title = "Everything tagged with " + @tag
    end
  end

end
