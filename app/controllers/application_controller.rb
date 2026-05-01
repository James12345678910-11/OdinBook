class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_suggested_users
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes


  def suggested_users
    @suggested_users = []
    return unless user_signed_in?

    followed_or_requested_ids = current_user.following_relationships.select(:followed_id)

    @suggested_users = User
    .where.not(id: current_user)
    .where.not(id: followed_or_requested_ids)
    .limit(10)
  end
end
