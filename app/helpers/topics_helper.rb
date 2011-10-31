# encoding: utf-8
module TopicsHelper
  def story_item_thumbnail(story, size="thumb")
    if size == "medium"
      img_url = story.image.url(:medium)
    else
      img_url = story.image.url(:thumb)
    end
    if story.image.exists?
      "<div class=\"storyItemThumbnail\">
      #{link_to image_tag(img_url), story}
      </div>".html_safe
    end
  end

  def story_item_icon(story)
    html = "<div class=\"storyItemIcon\">"
    if story.kind != Story::Rss
      html << "#{link_to gravatar_image_tag(story.user.email, :gravatar => { :size => 12 }), story.user, :title => story.user.login}"
    else
      html << "#{link_to image_tag(favicon_url(story.source_url), :class => "storyItemIcon"), story.source_url}"
    end
    html << "</div>"
    html.html_safe
  end

  def story_item_meta(story)
    html = "<div class=\"storyItemMeta\">"
    if story.kind != Story::Rss
      html << "Posted by #{story_item_icon(story)} #{link_to story.user.login,
      { :controller => "users", :action => "show", :id => story.user.id }} "
    else
      html << "#{story_item_icon(story)}"
      html << "#{link_to story.source, story.source_url} "
    end
    html << "• #{time_ago_in_words story.created_at} ago
    • #{link_to story.comments.count.to_s + ' comments', story}
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
    "<h4>
    #{link_to title, story}
    <br>
    </h4>".html_safe
  end
end