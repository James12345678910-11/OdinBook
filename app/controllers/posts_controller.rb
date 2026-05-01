class PostsController < ApplicationController
	before_action :set_post, only: [:destroy, :repost]
	
    def index
  		@user = User.find(params[:user_id])

 			# Posts from user + following
  		user_ids = [@user.id] + @user.following_ids
  		base_posts = Post.where(user_id: user_ids)

  		# Posts the user liked
  		liked_posts = Post.joins(:likes).where(likes: { user_id: @user.id })

  		# Combine everything
  		@posts = Post
    	.includes(:user, :likes, :comments, :original_post, original_post: [:user, :likes, :comments])
    	.where(id: base_posts.select(:id))
    	.or(Post.where(id: liked_posts.select(:id)))
    	.distinct
   		.order(created_at: :desc)
		end

    def show
        @post = Post.where(user_id: params[:user_id], id: params[:id]).first
    end

    def new
        @post = Post.new
    end

    def create
        @post = current_user.posts.build(posts_params)
        
        if @post.save
            redirect_to user_post_path(current_user, @post), notice: 'Post created successfully.'
        else
            load_feed_post
			@failed_comment_post_id = nil
			render :index, status: :unprocessable_entity
        end
    end

    def destroy
        @post = current_user.posts.find(params[:id])
        @post.destroy
        redirect_to user_posts_path(current_user), notice: 'Post deleted successfully.'
    end

    def repost
        target_post = @post.original_post || @post
        existing_repost = current_user.posts.find_by(original_post: target_post)

        if existing_repost
            existing_repost.destroy
            redirect_back(fallback_location: posts_path, notice: 'Repost removed.')
            return
        end
        repost = current_user.posts.build(original_post: target_post)
        	if repost.save
						redirect_back(fallback_location: posts_path, notice: 'Post reposted successfully.')
					else
						redirect_back(fallback_location: posts_path, alert: 'Failed to repost.')
					end

				rescue ActiveRecord::RecordNotUnique
					redirect_back(fallback_location: posts_path, alert: 'You have already reposted this post.')
    end

		private

		def posts_params
			params.require(:post).permit(:content, images: [])
		end

		def set_post
			@post = Post.find(params[:id])
		end

		def load_feed_post
			followed_user_ids = current_user.following_ids.where(status: :accepted).pluck(:followed_id)
			@post = Post.includes(:user, :likes, :comments, :original_post, original_post: [:user, :likes, :comments])
			.where(user_id: followed_users_ids + [current_user.id])
			.order(created_at: :desc)
		end

end



