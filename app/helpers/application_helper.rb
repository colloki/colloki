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

  def colloki_description
    ("Colloki is a place to learn and discuss local issues with 
    other Blacksburg and Montgomery County residents.<br><br>" +  
    " Sign up today to participate in discussions!<br><br>" + 
    link_to('Sign Up', signup_url, :class => 'btn btn-primary')).html_safe
  end

  def errors_for(object, message=nil)
    html = ""
    unless !(defined? object.errors) or object.errors.blank?
      html << "<div class='formErrors #{object.class.name.humanize.downcase}Errors'>\n"
      if message.blank?
        if object.new_record?
          html << "\t\t<div class='alert'>There was a problem creating the #{object.class.name.humanize.downcase}</div>\n"
        else
          html << "\t\t<div class='alert'>There was a problem updating the #{object.class.name.humanize.downcase}</div>\n"
        end
      end
      if object.errors.full_messages.count != 0
        html << "\t\t\t<div class='alert-error alert' data-dismiss='alert'><a class='close' href='#'>&times;</a>"
        html << "<p><strong>#{message}...</strong></p><br>"
        object.errors.full_messages.each do |error|
          html << "<p>#{error}</p>"
        end
        html << "</div>"
      end
      html << "\t</div>\n"
    end
    html
  end
end