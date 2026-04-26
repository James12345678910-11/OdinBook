class Post < ApplicationRecord
  belongs_to :user
  belongs_to :original_post, class_name: 'Post', optional: true
  has_many :reposts, class_name: 'Post', foreign_key: 'original_post_id', dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many_attached :images

  before_validation :set_root_post

  validate :image_count_limit      
  validate :image_type             
  validate :image_size            
  validate :prevent_repost_of_repost  

  validates :content, presence: true, length: { maximum: 500 }
  

  ALLOWED_IMAGE_TYPES = [ "image/jpeg", "image/png", "image/webp" ].freeze
  MAX_IMAGE_SIZE = 5.megabytes
  MAX_IMAGE_COUNT = 4

  def set_root_post
  return unless original_post

  self.original_post = original_post.original_post || original_post
  end

  def repost_count
    reposts.count
  end

  def repost?
    original_post_id.present?
  end

  def liked_by?(user)
    likes.exists?(user_id: user.id)
  end

  private

  def image_count_limit
    if images.attached? && images.count > MAX_PHOTO_COUNT
      errors.add(:images, "You can attach up to #{MAX_PHOTO_COUNT} images")
    end
  end

  def image_type
    images.each do |img|
      next if ALLOWED_IMAGE_TYPES.include?(img.content_type)

      errors.add(:images, "must be a JPEG, PNG, or GIF")
    end
  end

  def image_size
    images.each do |img|
      next if img.byte_size <= MAX_IMAGE_SIZE

      errors.add(:images, "size must be less than 5MB")
      end
    end
  end

def prevent_repost_of_repost
  return unless self.original_post
  return unless self.original_post.original_post

  errors.add(:base, "Cannot repost a repost")
end
end
