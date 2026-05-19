class UsersController < ApplicationController
    before_action :authenticate_user!, only: [:follow_requests]
    before_action :set_user, only: [:show]
    def index
        @users = User.all
        @posts = Post.where(user_id: [current_user.id] + current_user.following_ids)
                                                                                    .order(created_at: :desc)
    end

    def show
        @posts = @user.posts.order(created_at: :desc)
    end

    def follow_requests
        @incoming_requests = current_user.follower_relationships.includes(:follower).where(status: 'pending')

        @outgoing_requests = current_user.following_relationships.includes(:followed).where(status: 'pending')
    end

    private

    def set_user
        @user = User.find(params[:id])
    end
end
