class UserMailer < ActionMailer::Base
  default :from => "ahuja.ankit@gmail.com"

  def signup_notification(user)
    setup_email(user)
    @subject += 'Please activate your new account'
    @url = activate_url(user.activation_code)
    mail(:to => user.email, :subject => @subject)
  end

  def activation(user)
    setup_email(user)
    @subject += 'Your account has been activated!'
    @url = root_url
    mail(:to => user.email, :subject => @subject)
  end

  def reset(user)
    setup_email(user)
    @subject += 'Your reset password link!'
    @url = reset_password_url(user.reset_code)
    mail(:to => user.email, :subject => @subject)
  end

  protected
    def setup_email(user)
      @subject     = "[Colloki] "
      @sent_on     = Time.now
      @user = user
    end
end
