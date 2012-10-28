require 'digest/sha1'

class User < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password, :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_length_of       :login, :within => 3..40
  validates_length_of       :email, :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  # Email validation
  validates_format_of :email,
      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
      :message => "can only be a valid Email"

  # Website URL validation
  validates_format_of :website,
              :with => /^$|(^(http|https):\/\/.+\..+)/ix,
              :message => "can only be a valid URL."

  before_save :encrypt_password
  before_create :make_activation_code

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation,
    :first_name, :last_name, :realname, :website,
    :bio, :location, :twitter_id, :facebook_url, :image_url

  # Relationships to other models
  has_many :comments, :dependent => :destroy
  has_many :stories, :dependent => :destroy
  has_many :activity_items, :dependent => :destroy
  has_many :topics
  has_many :provider_authentications
  has_many :votes, :dependent => :destroy

  # Follow and get followed
  acts_as_followable
  acts_as_follower

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # todo: admin name is ankit here. Move this to a config somewhere
  # todo: probably not the best way or safe, but works for now...
  def is_admin?
    if login == "ankit"
      return true
    else
      return false
    end
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
    self.remember_token = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token = nil
    save
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def make_reset_code
    self.reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def apply_omniauth(omniauth)
    self.email = omniauth['info']['email'] if email.blank?
    self.login = omniauth['info']['nickname'] if login.blank?
    self.website = omniauth['info']['website'] if website.blank?
    self.realname = omniauth['info']['name'] if realname.blank?
    self.image_url = omniauth['info']['image'].sub("_normal", "").sub("=square", "=large")
    provider_authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def voted_on?(story)
    self.votes.any?{|vote| vote.story_id == story.id}
  end

  def vote(story)
    vote = self.votes.create(:story_id => story.id)
    self.save
    vote
  end

  def get_vote(story)
    Vote.find(:first, :conditions => {:user_id => self.id, :story_id => story.id})
  end

  def unvote(vote)
    story = vote.story
    vote.delete
    story.save
  end

  def get_image_url
    if self.image_url
      return self.image_url
    else
      return Gravatar.new(self.email).image_url
    end
  end

  def self.top_in_topic(topic_id)
    User.find_by_sql("SELECT a.id, a.email, a.login, a.activated_at,
      (SELECT count(*) FROM stories b WHERE b.user_id = a.id AND topic_id = #{topic_id}) as story_count FROM users a WHERE
      a.activated_at IS NOT NULL
      LIMIT 0, 10")
  end

  def self.newly_activated
    find(:all, :conditions => "activated_at IS NOT NULL", :order => "created_at DESC")
  end

  protected
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      provider_authentications.empty? && (crypted_password.blank? || !password.blank?)
    end

    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
end
