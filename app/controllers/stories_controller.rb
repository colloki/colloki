class StoriesController < ApplicationController
  # TODO: The URL for this action is currently http://site/stories/<ID>.
  # It needs to be http://site/topic/<Topic_ID>/story/<ID>
  # or if topics get mnemonics, then, http://site/<topic-mnemonic>/{links|posts}/<ID>
  def show
    @story = Story.includes(:comments => :user).find(params[:id])

    if (!@story)
      redirect_to root_url
    end

    if @story.topic_id != -1
      # topic maybe invalid..
      begin
        @topic = Topic.find(@story.topic_id)
        @more_stories = Story.find :all,
          :conditions => "topic_id = #{@topic.id} AND id != #{@story.id}",
          :order => "created_at DESC",
          :limit => 5
      rescue
      end
    end

    if @story.source
      if @story.topic_id != -1 and @topic
        @more_stories_from_source = Story.find :all,
          :conditions => "source = '#{@story.source}'
                          AND id != #{@story.id}
                          AND topic_id != #{@topic.id}",
          :order => "published_at DESC",
          :limit => 5
      else
        @more_stories_from_source = Story.find :all,
          :conditions => "source = '#{@story.source}'
                          AND id != #{@story.id}",
          :order => "published_at DESC",
          :limit => 5
      end

    elsif @story.kind == Story::Post
      @user_posted_stories = Story.find :all,
        :conditions => ["user_id = ?", @story.user.id],
        :order => "published_at DESC",
        :limit => 5
      @all_posted_stories = Story.find :all,
        :conditions => ["kind = ? and user_id != ?", Story::Post, @story.user.id],
        :order => "published_at DESC",
        :limit => 5
    end

    @page_title = @story.title

    if @story.views == nil
      @story.views = 1
    else
      @story.views = @story.views + 1
    end

    # TODO: Find a way to score unique visits
    # if !current_user or current_user == @story.user
    #   @story.increase_popularity(Story::ScoreVisit)
    # end

    @story.save

    @likers = []
    for vote in @story.votes
      @likers << User.find(vote[:user_id])
    end

    if logged_in?
      @user_id = current_user.id
    else
      @user_id = -1
    end

    @related_posts = @story.related_posts

    gon.story = @story
    gon.votes = @story.votes
    gon.comments = @story.comments
    gon.app_url = root_url
    gon.user = current_user
    gon.current_user = current_user

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @story }
    end
  end

  # GET /stories/new
  def new
    if not logged_in?
      flash[:alert] = "You need to be logged in to post a photo."
      redirect_to login_url
    else
      gon.user = current_user
      gon.current_user = current_user

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
    @story.views = 0

    if logged_in?
      @story.user_id = current_user.id
      @story.update_popularity
      if @story.save
        if @story.is_link?
          current_user.activity_items.create(
            :story_id => @story.id,
            :topic_id => @topic.id,
            :kind     => ActivityItem::CreateLinkType)
        else
          current_user.activity_items.create(
            :story_id => @story.id,
            :topic_id => @topic.id,
            :kind     => ActivityItem::CreatePostType)
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
      flash[:alert] = "You need to login to post stories!"
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
      flash[:alert] = "You need to login to delete a story!"
      redirect_back_or(root_url)
    elsif current_user.is_admin?
      @story = Story.find(params[:id])
      @title = @story.title
      @topic = @story.topic
      @story.destroy
      flash[:notice] = "The story '" << @title << " ' was successfully deleted!"
      redirect_to root_url
    elsif not current_user.id == Story.find(params[:id]).user.id
      flash[:alert] = "You need to be the author of the story to delete it!"
      redirect_back_or(root_url)
    else
      @story = Story.find(params[:id])
      @title = @story.title
      @topic = @story.topic
      @story.destroy
      flash[:notice] = "The story '" << @title << " ' was successfully deleted!"
      redirect_to root_url
    end
  end

  def feed_interface
    @error_msg = params[:error_msg]
  end

  def send_email
    UserMailer.share_story(
      params[:from],
      params[:to],
      params[:message][0],
      params[:story]).deliver
    flash[:notice] = "Email was successfully sent!"
    redirect_back_or root_url
  end
end
