class Api::V1::PostsController < ApplicationController
  def create
    @group = Group.find_by_id(params[:id])
    @post = @group.posts.build(post_params)
    respond_to do |format|
      if @post.save
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

  def destroy
  end

  def all_posts
  end

  def show_post
  end

  def edit
  end

  private
  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.permit(:title, :content, :last_activity, :group_id, :user_id, :images)
  end
end
