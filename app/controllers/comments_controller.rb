class CommentsController < ApplicationController
    before_action :set_comment, only: [:destroy, :update]

    def new
        @comment = Comment.new
    end

    def create
        @comment = current_user.comments.build(comment_params)
        if @comment.save
            redirect_back(fallback_location: posts_path, notice: 'Comment added successfully.')
        else
            redirect_back(fallback_location: posts_path, alert: 'Unable to add comment.')
        end
    end

    def update
        unless @comment.user_id == current_user.id
            redirect_back(fallback_location: posts_path, alert: 'You can only edit your own comments.')
            return
        end
        if @comment.update(comment_params)
            redirect_back(fallback_location: posts_path, notice: 'Comment updated successfully.')
        else
            redirect_back(fallback_location: posts_path, alert: 'Unable to update comment.')
        end
    end

    def destroy
        unless @comment.user_id == current_user.id
            redirect_back(fallback_location: posts_path, alert: 'You can only delete your own comments.')
            return
        end
        if @comment.destroy
            redirect_back(fallback_location: posts_path, notice: 'Comment deleted successfully.')
        else
            redirect_back(fallback_location: posts_path, alert: 'Unable to delete comment.')
        end

        private

        def comment_params
            params.require(:comment).permit(:content, :post_id, :image)
        end

        def set_comment
            @comment = Comment.find(params[:id])
        end
    end
