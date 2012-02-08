module FeedsHelper
  def story_image(story)
    img_url = root_url[0..-2] + story.image.url(:medium)
    if story.image.exists?
      return link_to image_tag(img_url), story_url(story)
    else
      return ""
    end
  end
end
