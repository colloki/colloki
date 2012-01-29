module FeedsHelper
  def story_image(story)
    img_url = request.protocol + request.host_with_port + story.image.url(:medium)
    if story.image.exists?
      return link_to image_tag(img_url), story
    else
      return ""
    end
  end
end
