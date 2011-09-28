# encoding: utf-8
module TopicsHelper
  def mini_story_thumbnail(story, size="thumb")
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

  def mini_story_icon(story)
    html = "<div class=\"storyItemIcon\">"
    if story.kind != Story::Rss
      html << "#{link_to gravatar_image_tag(story.user.email, :gravatar => { :size => 15 }), story.user, :title => story.user.login}"
    else
      # todo: get favicon!
    end
    html << "</div>"
    html.html_safe
  end

  def mini_story_meta(story)
    html = "<div class=\"storyItemMeta\">"
    if story.kind != Story::Rss
      html << "By #{mini_story_icon(story)} #{link_to story.user.login,
      { :controller => "users", :action => "show", :id => story.user.id }}"
    else
      html << "#{link_to story.source, story.source_url} "
    end
    html << "• #{time_ago_in_words story.created_at} ago
    • #{link_to story.comments.count.to_s + ' comments', story}
    </div>"
    html.html_safe
  end

  def mini_story_content(story, length_with_image=80, length_without_image=200)
    if story.image.exists?
      return truncate(strip_tags(story.description), :length => length_with_image, :omission => "...")
    else
      return truncate(strip_tags(story.description), :length => length_without_image, :omission => "...")
    end
  end

  def mini_story_title(story)
    "<h4>
    #{link_to truncate(strip_tags(story.title), :length => 50, :omission => "..."), story}
    <br>
    </h4>".html_safe
  end
end