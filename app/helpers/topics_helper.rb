# encoding: utf-8
module TopicsHelper
  def story_item_thumbnail(story, size="thumb")
    if size == "medium"
      img_url = story.image.url(:medium, :host=>request.host)
    else
      img_url = story.image.url(:thumb, :host=>request.host)
    end
    if story.image.exists?
      return link_to image_tag(img_url), story
    else
      return ""
    end
  end

  def story_item_icon(story)
    html = "<div class=\"favicon\">"
    if story.kind != Story::Rss
      html << "#{link_to gravatar_image_tag(story.user.email, :gravatar => { :size => 12 }), story.user, :title => story.user.login}"
    else
      html << "#{link_to image_tag(favicon_url(story.source_url), :class => "storyItemIcon"), story.source_url}"
    end
    html << "</div>"
    return html.html_safe
  end

  def story_item_meta(story)
    html = "<div class=\"meta\">"
    if story.kind != Story::Rss
      html << "Posted by #{story_item_icon(story)} #{link_to story.user.login,
      { :controller => "users", :action => "show", :id => story.user.id }} "
    else
      html << "#{story_item_icon(story)}"
      html << "#{link_to story.source, story.source_url} "
    end
    if story.published_at
      html << "<br>#{time_ago_in_words story.published_at} ago"
    else
      html << "<br>#{time_ago_in_words story.created_at} ago"
    end
    html << "  •  "
    html << "
      #{link_to story.comments.count.to_s,
      story_path(story.id) + "#comments",
      :class => 'comment-count',
      :title => story.comments.count.to_s + ' comments'}"
    html << "  •  "
    html << "
      #{link_to story.votes.count.to_s,
      story_path(story.id),
      :class => 'like-count',
      :title => story.votes.count.to_s + " likes"}
    </div>"
    html.html_safe
  end

  def story_item_content(story, length_with_image=-1, length_without_image=-1)
    if story.image.exists?
      if length_with_image != -1
        return truncate(strip_tags(story.description), :length => length_with_image, :omission => "...")
      else
        return strip_tags(story.description)
      end
    else
      if length_without_image != -1
        return truncate(strip_tags(story.description), :length => length_without_image, :omission => "...")
      else
        return strip_tags(story.description)
      end
    end
  end

  def story_item_title(story, length=-1)
    if length != -1
      title = truncate(strip_tags(story.title), :length => length, :omission => "...")
    else
      title = strip_tags(story.title)
    end
    "<h5>
    #{link_to title, story}
    </h5>".html_safe
  end
end