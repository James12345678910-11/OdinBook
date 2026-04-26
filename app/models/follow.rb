class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  enum status: { pending: 0, accepted: 1, rejected: 2 }


  validates :follower_id, uniqueness: { scope: :followed_id }
  validates :no_self_follow

  private

  def no_self_follow
    if follower_id == followed_id
      errors.add(:follower_id, "can't follow yourself")
    end
  end 
end
