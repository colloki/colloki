# encoding: utf-8
module StoriesHelper

  def story_title(story)
    html = "<div class=\"story-title\">"
    if story.kind == Story::Link
      html << "#{link_to story.title, story.url}"
    else
      html << story.title
    end
    html << "</div>"
    html.html_safe
  end

  def sidebar_story_image(story)
    if story.image_exists?
      return link_to image_tag(story.image.url(:thumb), :class=>'sidebar-story-thumb'), story
    else
      return ""
    end
  end

  def sidebar_story(story)
    html = "<div class='sidebar-story row-fluid'>"

    if story.image_exists?
      html += "<div class='span1' style='width: 100px;'>"
    else
      html += "<div class='span1' style='width: 20px'>"
    end

    if story.kind == Story::Post
      html += link_to gravatar_image_tag(story.user.email,
                :gravatar => { :size => 20 }, :class => "favicon"),
                story.user,
                :title => story.user.login
    else
      html += link_to image_tag(favicon_url(story.source_url), :class => "favicon"), story.source_url
    end

    html += sidebar_story_image(story)
    html += "</div>"

    if story.image_exists?
      html += "<div class='span7 sidebar-story-content'>"
    else
      html += "<div class='span8 sidebar-story-content'>"
    end

    html += link_to story.title, story
    html += "</div>"
    html += "</div>"
    html.html_safe
  end
end
