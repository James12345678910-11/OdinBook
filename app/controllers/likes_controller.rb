class LikesController < ApplicationController
    before_action :set_like, only: [:destroy]

    def create
        @like = current_user.likes.build(like_params)
        if @like.save
            redirect_back(fallback_location: posts_path, notice: 'Post liked successfully.')
        else
            redirect_back(fallback_location: posts_path, alert: 'Unable to like post.')
        end
    end

    def destroy
        if @like.user_id == current_user.id
            @like.destroy
            redirect_back(fallback_location: posts_path, notice: 'Unliked succesfully.')
        else
            redirect_back(fallback_location: posts_path, alert: 'Unable to remove like.')
        end
    end

    private

    def like_params
        params.require(:like).permit(:post_id, :comment_id)
    end

    def set_like
        @like = Like.find(params[:id])
    end

end
