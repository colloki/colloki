class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    # CRITICAL TODO: Need to change this to pick up URL dynamically. root_url is not working here.
    @body[:url]  = "http://slurp.cs.vt.edu/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = 'http://slurp.cs.vt.edu'
  end
  
  def reset(user)
    setup_email(user)
    @subject    += 'Your reset password link!'
    @body[:url]  = "http://slurp.cs.vt.edu/reset_password/#{user.reset_code}"
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "slurp@slurp.cs.vt.edu"
      @subject     = "[Slurp!] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
