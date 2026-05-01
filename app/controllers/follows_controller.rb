class FollowsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_follow, only: [:update, :destroy]

    def create
       @follow = current_user.following_relationships.build(follow_params.merge(status: 'pending'))

       if follow.save
        redirect_back(fallback_location: users_path, notice: 'Follow request sent')
       else
        redirect_back(fallback_location: users_path, alert: 'Unable to send follow request')
       end
    end

    def update

        unless @follow.followed_id == current_user.id
            redirect_back(fallback_location: users_path, alert: 'You can only accept follow requests for yourself.')
            return
        end

        new_status = params[:status].presence || 'accepted'

            if @follow.update(status: 'accepted')
                redirect_back(fallback_location: users_path, notice: 'Follow request #{new_status}.')
            else
                redirect_back(fallback_location: users_path, alert: 'Unable to update follow request.')
            end

    end

    def destroy
        unless @follow.follower_id == current_user.id || @follow.followed_id == current_user.id
            redirect_back(fallback_location: users_path, alert: 'You can only unfollow users that you follow.')
            return
        end

            @follow.destroy

            respond_to do |format|
                format.turbo_stream
                format.html { redirect_back(fallback_location: root_path) }
            end
        end

    end

    private

    def follow_params
        params.permit(:followed_id)
    end

    def set_follow
        @follow = Follow.find(params[:id])
    end
end
