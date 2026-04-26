class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  has_many :likes, dependent: :destroy

  has_one_attached :image

  validate :image_type  
  validate :image_size  

  ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/png', 'image/gif'].freeze
  MAX_IMAGE_SIZE = 5.megabytes
  

  private

  def image_type
    return unless image.attached?

    unless ALLOWED_IMAGE_TYPES.include?(image.content_type)
      errors.add(:image, "must be a JPEG, PNG, or GIF")
    end
  end

  def image_size
    return unless image.attached?

    if image.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, "size must be less than 5MB")
    end
  end
end
