# encoding: utf-8
module StoriesHelper
  def likers(likers)
    output = ""
    for user in likers
      output += link_to gravatar_image_tag(user.email, :gravatar => { :size => 36 }), user
    end
    return output.html_safe
  end
end