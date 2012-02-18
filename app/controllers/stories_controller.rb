class StoriesController < ApplicationController
  # TODO: The URL for this action is currently http://site/stories/<ID>.
  # It needs to be http://site/topic/<Topic_ID>/story/<ID>
  # or if topics get mnemonics, then, http://site/<topic-mnemonic>/{links|posts}/<ID>
  def show
    @story = Story.find(params[:id])

    if (!@story)
      redirect_to root_url
    end

    if @story.topic_id != -1
      @topic = Topic.find(@story.topic_id)
      @more_stories = Story.find :all,
        :conditions => "topic_id = #{@topic.id} AND id != #{@story.id}",
        :order => "created_at DESC",
        :limit => 5
    end

    if @story.source
      @more_stories_from_source = Story.find :all,
        :conditions => "source = '#{@story.source}' 
                        AND id != #{@story.id} 
                        AND topic_id != #{@topic.id}",
        :order => "created_at DESC",
        :limit => 5
    end

    @page_title = @story.title

    if @story.views == nil
      @story.views = 1
    else
      @story.views = @story.views + 1
    end

    @story.update_popularity
    @story.save

    @likers = []
    for vote in @story.votes
      @likers << User.find(vote[:user_id])
    end

    @comments = []
    @story.comments.each do |comment|
      @comments.push({
        :id               => comment.id,
        :body             => comment.body,
        :user_login       => comment.user.login,
        :user_email_hash  => Digest::MD5.hexdigest(comment.user.email),
        :user_id          => comment.user.id,
        :timestamp        => comment.created_at
      })
    end

    state = 0
    if logged_in?
      if (@story.user && @story.user.id == current_user.id) || current_user.voted_on?(@story)
        state = 1
      end
    else
      state = -1
    end

    @voting_data = {
      state: state,
      id: (logged_in? and state == 1) ? current_user.get_vote(@story).id : nil,
      story_id: @story.id,
      user_id: logged_in? ? current_user.id : nil,
      user_email_hash: logged_in? ? Digest::MD5.hexdigest(current_user.email) : nil,
      user_login: logged_in? ? current_user.login : nil,
      count: @story.votes.count
    };

    if logged_in?
      @user_id = current_user.id
    else
      @user_id = -1
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @story }
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
      if params[:kind] == "link"
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
      elsif params[:kind] == "post"
        @story.kind = Story::Post
      elsif params[:kind] == "rss"
        @story.kind = Story::Rss
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

  def feed_interface
    @error_msg = params[:error_msg]
  end
end