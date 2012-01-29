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

  def story_meta(story)
    html = "<div class=\"story-meta\">"
    if story.kind != Story::Rss
      html << "by #{link_to story.user.login, story.user} • "
      html << "#{time_ago_in_words @story.published_at} ago "
      if logged_in? and story.user_id == current_user.id
        html << "• #{link_to 'edit', edit_story_path(story), :class=>'btn'} • "
        html << "#{link_to 'delete', story,
        :confirm => 'Are you sure you want to delete this post? You will not be able to restore it later.',
        :method => :delete,
        :class => 'btn error'}"
      end
    else
      html << "#{link_to image_tag("http://www.google.com/s2/favicons?domain_url=" << story.source_url, :class => "favicon"), story.source_url}"
      html << "#{link_to story.source, story.source_url} • "
      html << "#{time_ago_in_words @story.published_at} ago "
    end
    html << "</div>"
    html.html_safe
  end

  def story_likers(likers)
    html = ""
    for user in likers
      html += link_to gravatar_image_tag(user.email, :gravatar => { :size => 24 }),
      user,
      :id => "liker#{user.id}",
      :class => "story-liker",
      :title => user.login
    end
    html.html_safe
  end

  def sidebar_story(story)
    html = "<div class='sidebar-story row'>"
    if story.image.exists?
      html += "<div class='span2'>"
    else
      html += "<div class='span'>"
    end
    if story.kind == Story::Rss
      html += link_to image_tag(favicon_url(story.source_url), :class => "favicon"), story.source_url
    else
      html += link_to gravatar_image_tag(story.user.email, :gravatar => { :size => 12 }), story.user, :title => story.user.login
    end
    if story.image.exists?
      html += link_to image_tag(story.image.url(:thumb), :class=>'sidebar-story-thumb'), story
    end
    html += "</div>"
    if story.image.exists?
      html += "<div class='span3 sidebar-story-content'>"
    else
      html += "<div class='span4 sidebar-story-content'>"
    end
    html += link_to story.title, story
    html += "</div>"
    html += "</div>"
    html.html_safe
  end
end