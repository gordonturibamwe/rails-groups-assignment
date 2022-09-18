class Api::V1::PostsController < ApplicationController
  def create
    @group = Group.find_by_id(params[:id])
    @post = @group.posts.build(post_params)
    @post.user_id = @user.id
    @post.mentions = params[:mentions].split(',')
    respond_to do |format|
      if @post.save
        @group.update(total_posts: @group.total_posts + 1)
        ActionCable.server.broadcast "PostsChannel", post_object(post: @post, action: 'create')
        ActionCable.server.broadcast "GroupsChannel", group_object(group: @post.group, action: 'update')
        mentions = @post.mentions
        post = @post
        Thread.new(mentions, post) {
          mentions.each do |id|
            user = User.find_by_id(id)
            ActionCable.server.broadcast "NotificationsChannel", {message: "You have been mentioned in post #{post.title}", recipient: user} if user # notification_object(message: "You have been invited to #{@group.name}", recipient: user, sender: @user, path: "group/#{@group.id}")
          end
        } if mentions.count > 0
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

  def update
    @post = Post.find_by_id(params[:post_id])
    respond_to do |format|
      if @post.update(post_params)
        ActionCable.server.broadcast "PostsChannel", post_object(post: @post, action: 'update')
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
      @group =  @post.group
      if @post.destroy
        @group.update(total_posts: @group.total_posts - 1)
        ActionCable.server.broadcast "PostsChannel", post_object(post: @post, action: 'destroy')
        ActionCable.server.broadcast "GroupsChannel", group_object(group: @post.group, action: 'update')
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

  def group_object(group:, action:)
    {
      id: group.id,
      name: group.name,
      group_access: group.group_access,
      total_posts: group.total_posts,
      total_members: group.total_members,
      last_activity: group.last_activity,
      user_id: group.user_id,
      user_exists_in_group: group.user_groups.find_by_user_id(@user.id),
      action: action
    }
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.permit(:title, :content, :last_activity, :mentions, :group_id, :user_id, :images)
  end
end
