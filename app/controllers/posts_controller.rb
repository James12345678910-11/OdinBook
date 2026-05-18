class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :destroy, :edit, :repost]

  def index
    user_ids = [current_user.id] + current_user.following_relationships
                                               .where(status: :accepted)
                                               .pluck(:followed_id)

    base_posts = Post.where(user_id: user_ids)
    liked_posts = Post.joins(:likes).where(likes: { user_id: current_user.id })

    @posts = Post.includes(:user, :likes, :comments, :original_post, original_post: [:user, :likes, :comments])
                 .where(id: base_posts.select(:id))
                 .or(Post.where(id: liked_posts.select(:id)))
                 .distinct
                 .order(created_at: :desc)
  end

  def show
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(posts_params)

    if @post.save
      redirect_to @post, notice: 'Post created successfully.'
    else
      load_feed_post
      @failed_comment_post_id = nil
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @post = current_user.posts.find(params[:id])
  end

  def update
    @post = current_user.posts.find(params[:id])
    if @post.update(posts_params)
      redirect_to @post, notice: 'Post updated successfully.'
    else
      load_feed_post
      @failed_comment_post_id = nil
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: 'Post deleted successfully.'
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
    followed_user_ids = current_user.following_relationships
                                    .where(status: :accepted)
                                    .pluck(:followed_id)

    @posts = Post.includes(:user, :likes, :comments, :original_post, original_post: [:user, :likes, :comments])
                 .where(user_id: followed_user_ids + [current_user.id])
                 .order(created_at: :desc)
  end
end