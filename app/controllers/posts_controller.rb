class PostsController < ApplicationController
  before_action :require_login, only: %i[new create edit update destroy]
  before_action :set_post, only: %i[show edit update destroy]

  def index
    @posts = Post.includes(:user, :tags, comments: :user)

    if params[:post].present?
      @posts = @posts.where("title ILIKE :q OR body ILIKE :q", q: "%#{params[:post]}%")
    end

    if params[:comment].present?
      @posts = @posts.joins(:comments).where("comments.body ILIKE ?", "%#{params[:comment]}%")
    end

    if params[:user].present?
      @posts = @posts.joins(user: :profile).where("profiles.name ILIKE ?", "%#{params[:user]}%")
    end

    if params[:tag_id].present?
      @posts = @posts.joins(:tags).where(tags: { id: params[:tag_id] })
    end

    @posts = @posts.distinct.order(created_at: :desc).page(params[:page]).per(10)
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)
    assign_tags(@post)
    if @post.save
      assign_tags(@post)
      redirect_to post_path(@post), success: 'ポストを作成しました'
    else
      flash.now[:danger] = 'ポストを作成できませんでした'
      render :new
    end
  end

  def show
    @comment = Comment.new
  end

  def edit
  end

  def update
    if @post.update(post_params)
      assign_tags(@post)
      redirect_to post_path(@post), success: 'ポストを更新しました'
    else
      flash.now[:danger] = 'ポストを更新できませんでした'
      render :edit
    end
  end

  private

  def set_post
    @post = current_user.posts.find_by(id: params[:id]) || Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :tags_string)
  end

  def assign_tags(post)
    tag_names = (params[:tags_string] || "").split(",").map(&:strip).uniq
    post.tags = tag_names.reject(&:blank?).map { |name| Tag.find_or_create_by(name: name) }
  end
end
