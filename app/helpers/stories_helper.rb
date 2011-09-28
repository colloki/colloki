# encoding: utf-8
module StoriesHelper

  def story_title(story)
    html = "<div class=\"storyTitle\">"
    if story.kind == Story::Link
      html << "#{link_to story.title, story.url}"
    else
      html << story.title
    end
    html << "</div>"
    html.html_safe
  end

  def story_meta(story)
    html = "<div class=\"storyMeta\">"
    if story.kind != Story::Rss
      html << "by #{link_to story.user.login, story.user} • "
      html << "#{time_ago_in_words @story.created_at} ago "
      if logged_in? and story.user_id == current_user.id
        html << "• #{link_to 'edit', edit_story_path(story)} • "
        html << "#{link_to 'delete', story,
        :confirm => 'Are you sure you want to delete this post? You will not be able to restore it later.',
        :method => :delete,
        :class => 'negative'}"
      end
    else
      html << "#{link_to story.source, story.source_url}"
    end
    html << "</div>"
    html.html_safe
  end

  def story_likers(likers)
    output = ""
    for user in likers
      output += link_to gravatar_image_tag(user.email, :gravatar => { :size => 36 }), user
    end
    output.html_safe
  end
end