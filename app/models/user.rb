# encoding: UTF-8

class User < ActiveRecord::Base
  key :name
  key :nickname
  key :locale
  key :email, :index => true
  key :email_confirmed
  key :crypted_password
  key :password_salt
  key :persistence_token
  key :single_access_token
  key :token
  key :location
  key :is_admin, :as => :boolean, :default => false
  key :facebook_friend_ids, :as => :text
  key :restricted_access, :as => :boolean, :default => false
  key :invitation_code
  key :karma, :as => :integer, :default => 0
  key :notifications_count, :as => :integer, :default => 0
  timestamps
  key :memberships_count, :as => :integer, :default => 0

  belongs_to :city
  has_many :absences, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :admined_groups, :through => :memberships, :source => :group, :conditions => {'memberships.is_admin' => true}
  has_many :authentications, :dependent => :destroy
  has_many :event_invitations, :dependent => :nullify
  has_many :events, :dependent => :nullify
  has_many :followers, :through => :user_follows, :source => :user
  has_many :group_invitations, :dependent => :nullify
  has_many :groups, :dependent => :nullify
  has_many :joined_events, :through => :participations, :source => :event
  has_many :joined_next_events, :through => :participations, :source => :event, :conditions => ['start_time > ?', Time.now], :order => 'start_time ASC'
  has_many :joined_groups, :through => :memberships, :source => :group
  has_many :memberships, :dependent => :destroy
  has_many :notifications, :dependent => :destroy
  has_many :participations, :dependent => :destroy
  has_many :reviews, :dependent => :destroy
  has_many :taggings, :dependent => :destroy
  has_many :tags, :through => :taggings
  has_many :user_follows, :dependent => :destroy
  has_many :wave_memberships, :dependent => :destroy
  has_many :waves, :through => :wave_memberships

  serialize :facebook_friend_ids
  acts_as_authentic do |c|
    c.validate_email_field = false
    c.validate_password_field = false
  end

  validates :email, :presence => {:if => :password_required?}
  validates :password, :presence => {:if => :password_required?}, :confirmation => true
  attr_protected :is_admin

  def password_required?
    authentications.blank? and crypted_password.blank? and not restricted_access
  end

  def admin?
    is_admin?
  end

  def guest?
    false
  end

  def mugshot
    false
  end

  def link
    false
  end

  def apply_omniauth(omniauth)
    case omniauth['provider']
      when 'facebook'
        self.token = omniauth['credentials']['token']
        self.facebook_friend_ids = facebook.friends.map(&:identifier)
    end
    save
  end

  def authenticated_with(provider)
    authentications.where(:provider => provider).first
  end

  def facebook
    @facebook ||= FbGraph::User.new(facebook_id, :access_token => self.token).fetch
  end

  def facebook_id
    @facebook_id ||= authentications.where(:provider => 'facebook').first.andand.uid
  end

  def twitter_id
    @twitter_id ||= authentications.where(:provider => 'twitter').first.andand.uid
  end

  def user_follow_for(user)
    UserFollow.find_by_followed_user_id_and_user_id(self.id, user.id)
  end

  def follow(user)
    UserFollow.create :followed_user_id => self.id, :user_id => user.id unless user_follow_for(user)
  end

  def unfollow(user)
    user_follow_for(user).andand.destroy
  end

  def followed_users
    User.joins('INNER JOIN user_follows ON user_follows.followed_user_id = users.id').where('user_follows.user_id' => 1)
  end

  def connect_facebook_friends
    Authentication.where(:provider => 'facebook', :uid => facebook_friend_ids).includes(:user).map(&:user).each do |user|
      follow(user)
      user.follow(self)
    end
  end

  def set_karma
    karma = user_follows.count * 5 +
      memberships.count * 10 +
      memberships(:is_admin => true) * 40
    update_column :karma, karma
  end

  if Settings.customization == 'get2gather'
    key :read_manual, :as => :boolean
    key :read_cobe, :as => :boolean

    validates :read_manual, :read_cobe, :presence => true
  end
end

User.auto_upgrade!
