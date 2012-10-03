class UserMailer < ActionMailer::Base
  default :from => "test.colloki@gmail.com"

  def signup_notification(user)
    setup_email(user)
    @subject += 'Please activate your new account'
    @url = activate_url(user.activation_code)
    mail(:to => user.email, :subject => @subject)
  end

  def activation(user)
    setup_email(user)
    @subject += 'Your account has been activated!'
    @url = root_url << "/users/" << user.id.to_s
    mail(:to => user.email, :subject => @subject)
  end

  def reset(user)
    setup_email(user)
    @subject += 'Your reset password link'
    @url = reset_password_url(user.reset_code)
    mail(:to => user.email, :subject => @subject)
  end

  def share_story(from, to, message, story)
    @subject = "[VTS] " + from[:name] + " shared a story from Virtual Town Square"
    @message = message
    @from_name = from[:name]
    @from_email = from[:email]
    @story = story
    mail(:to => to[:email], :subject => @subject)
  end

  def blog_suggestion(blog)
    @subject = "[VTS] Blog suggestion received"
    @blog = blog
    # todo: the :to should be in a config somewhere..
    mail(:to => 'ahuja.ankit@gmail.com', :subject => @subject)
  end

  protected
    def setup_email(user)
      @subject = "[VTS] "
      @sent_on = Time.now
      @user = user
    end
end
