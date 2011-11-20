# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include ActsAsTaggableOn::TagsHelper

  def sort_selected?(sort_name)
   params[:sort].to_s == sort_name.to_s
  end

  def renderSortTab(name, url, sort_name)
    if sort_selected?(sort_name)
      s = "<span class='sortTabSelected'>" + name + "</span>"
    else
      s = "<span class='sortTab'>" + link_to(name, url) + "</span>"
    end
    s.html_safe
  end

  def favicon_url(url)
    "http://www.google.com/s2/favicons?domain_url=" << url
  end

  # Returns some descriptive text about Colloki
  def colloki_description
    "A place to engage in discussions on local issues with other Blacksburg and Montgomery County residents"
  end
end