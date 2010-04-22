require 'digest/sha1'
class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  
  #Adding email validation
  validates_format_of :email,
      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
      :message => "can only be a valid Email"
  
  
  #facebook profile URL validation
  validates_format_of :facebook_url,
              :with => /^$|(^(http|https):\/\/.*facebook.com.*profile\.php.*)/ix,
              :message => "can only be a valid Facebook Profile URL."

  #Website URL validation
  validates_format_of :website,
              :with => /^$|(^(http|https):\/\/.+\..+)/ix,
              :message => "can only be a valid URL."


  #linkedin profile URL validation
  validates_format_of :linkedin_url,
              :with => /(^$)|(^(http):\/\/.*linkedin\.com.*)/ix,
              :message => "can only be a valid LinkedIn Profile URL."
  
  before_save :encrypt_password
  before_create :make_activation_code 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :first_name, :last_name, :realname, :website, :bio, :location, :twitter_id, :delicious_id, :friendfeed_id, :linkedin_url, :facebook_url
  
  #Relationships
  has_many :comments, :dependent => :destroy
  has_many :stories, :dependent => :destroy
  has_many :activity_items, :dependent => :destroy
  has_many :topics
  acts_as_voter
  
  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    if !u
      u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', login]
    end
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def make_reset_code
    self.reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def User.top_in_topic(topic_id)
      #TODO: very soon we will need to do this differently, with a seperate table.
      User.find_by_sql("SELECT a.id, a.email, a.login, a.activated_at, 
        (SELECT count(*) FROM stories b WHERE b.user_id = a.id AND topic_id = #{topic_id}) as story_count FROM users a WHERE 
        a.activated_at IS NOT NULL
        LIMIT 0, 10")
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    
end
