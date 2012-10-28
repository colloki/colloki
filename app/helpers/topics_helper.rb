# encoding: utf-8
module TopicsHelper

  def story_item_thumbnail(story, size="thumb")
    if story.image_exists?
      if story.image_url
        img_url = story.image_url
      else
        if size == "medium"
          img_url = story.image.url(:medium, :host => request.host)
        elsif size == "original"
          img_url = story.image.url(:original, :host => request.host)
        else
          img_url = story.image.url(:thumb, :host => request.host)
        end
      end
      return link_to image_tag(img_url), story
    else
      return ""
    end
  end

  def story_item_icon(story)
    html = "<div class=\"favicon\">"
    if story.kind == Story::Post
      html << "#{link_to image_tag(story.user.get_image_url), story.user, :title => story.user.login}"
    else
      html << "#{link_to image_tag(favicon_url(story.source_url), :class => "favicon-icon"), story.source_url}"
    end
    html << "</div>"
    return html.html_safe
  end

  def story_item_content(story, length_with_image=-1, length_without_image=-1)
    if story.image_exists?
      if length_with_image != -1
        return truncate(strip_tags(story.description),
                :length => length_with_image,
                :omission => "...")
      else
        return strip_tags(story.description)
      end
    else
      if length_without_image != -1
        return truncate(strip_tags(story.description),
                :length => length_without_image,
                :omission => "...")
      else
        return strip_tags(story.description)
      end
    end
  end
end
