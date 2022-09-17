class Api::V1::PostsController < ApplicationController
  def create
    @group = Group.find_by_id(params[:id])
    @post = @group.posts.build(post_params)
    @post.user_id = @user.id
    respond_to do |format|
      if @post.save
        ActionCable.server.broadcast "PostsChannel", post_object(post: @post, action: 'create')
        format.json {render status: :ok}
      else
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages(@post.errors.messages)
        }
      end
    end
  rescue => exception
    respond_to do |format|
      format.json {
        render status: :unprocessable_entity,
        json: error_response_messages({error: [exception.message]})
      }
    end
  end

  def group_posts
    respond_to do |format|
      @group = Group.find_by_id(params[:group_id])
      @posts = @group.posts.order(created_at: :desc)
      format.json {render status: :ok}
    end
  end


  def destroy
    respond_to do |format|
      @post = Post.find_by_id(params[:post_id])
      if @post.destroy
        format.json {render status: :ok}
      else
        format.json {render status: :unprocessable_entity}
      end
    end
  end

  def show_post
  end

  def edit
  end

  private
  def post_object(post:, action:)
    {
      id: post.id,
      title: post.title,
      content: post.content,
      last_activity: post.last_activity,
      user_id: post.user_id,
      group_id: post.group_id,
      user: {id: post.user.id, username: post.user.username},
      action: action
    }
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.permit(:title, :content, :last_activity, :group_id, :user_id, :images)
  end
end
