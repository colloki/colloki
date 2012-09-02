# encoding: utf-8
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

  def errors_for(object, message=nil)
    html = ""
    unless !(defined? object.errors) or object.errors.blank?
      html << "<div class='formErrors #{object.class.name.humanize.downcase}Errors'>\n"
      if object.errors.full_messages.count != 0
        html << "\t\t\t<div class='alert-error alert' data-dismiss='alert'>"
        html << "<a class='close' href='#'>&times;</a>"
        if message
          html << "<p><strong>#{message}</strong></p><br>"
        end

        if object.errors.count != 1
          object.errors.full_messages.each do |error|
            html << "<p>#{error}</p>"
          end
        else
          html << "#{object.errors.full_messages[0]}"
        end

        html << "</div>"
      elsif message.blank?
        if object.new_record?
          html << "<div class='alert'>"
          html << "There was a problem creating the #{object.class.name.humanize.downcase}"
          html << "<a class='close' href='#'>&times;</a>"
          html << "</div>"
        else
          html << "<div class='alert'>"
          html << "There was a problem updating the #{object.class.name.humanize.downcase}"
          html << "<a class='close' href='#'>&times;</a>"
          html << "</div>"
        end
      end
      html << "\t</div>\n"
    end
    html.html_safe
  end

  def is_admin?
    return current_user ? (current_user.login == "ankit") : false
  end
end
