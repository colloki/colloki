# encoding: utf-8
module TopicsHelper
  def story_thumbnail(story)
    if story.image.exists?
      "<div class=\"storyItemThumbnail\">
      #{link_to image_tag(story.image.url(:thumb)), story}
      </div>".html_safe
    end
  end

  def story_icon(story)
    "<div class=\"storyItemIcon\">
    #{link_to gravatar_image_tag(story.user.email, :gravatar => { :size => 15 }), story.user, :title => story.user.login}
    </div>".html_safe
  end

  def story_meta(story)
    author = link_to story.user.login, { :controller => "users", :action => "show", :id => story.user.id }
    "<div class=\"storyItemMeta\">
    By #{author} • #{time_ago_in_words story.created_at} ago
    • #{link_to story.comments.count.to_s + ' comments', story}
    </div>".html_safe
  end

  def story_content(story, length_with_image=80, length_without_image=200)
    if story.image.exists?
      return truncate(strip_tags(story.description), :length => length_with_image, :omission => "...")
    else
      return truncate(strip_tags(story.description), :length => length_without_image, :omission => "...")
    end
  end

  def story_title(story)
    "<h4>
    #{link_to truncate(strip_tags(story.title), :length => 50, :omission => "..."), story}
    <br>
    </h4>".html_safe
  end
end