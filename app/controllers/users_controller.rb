class UsersController < ApplicationController
    before_action :authenticate_user!, only: [:follow_requests]
    before_action :set_user, only: [:show]
    def index
        @users = @suggested_users
    end

    def show
        @user = User.find(params[:id])
    end

    def follow_requests
        @incoming_requests = current_user.follower_relationships.includes(:follower).where(status: 'pending')

        @outgoing_requests = current_user.following_relationships.includes(:followed).where(status: 'pending')
    end
end
