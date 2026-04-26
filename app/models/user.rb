class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create :send_welcome_email

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy


  #followers
  has_many :follower_relationships, foreign_key: :followed_id, class_name: 'Follow', dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower
  #following
  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow', dependent: :destroy
  has_many :following, through: :following_relationships, source: :followed

   def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.avatar_url = auth.info.image
    end
  end

   def profile_picture(size: 200)
    avatar_url.presence || gravatar_url(size: size)
  end

  private

  def send_welcome_email
    UserMailer.with(user: self).welcome_email.deliver_later
  end

  def gravatar_url(size: 200)
    email_hash = Digest::MD5.hexdigest(email.downcase)
    "https://www.gravatar.com/avatar/#{email_hash}?s=#{size}&d=identicon"
  end
end
