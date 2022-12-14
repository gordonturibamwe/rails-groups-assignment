class Api::V1::GroupsController < ApplicationController
  include Api::V1::GroupsHelper
  before_action :set_group, except: [:create, :all_groups, :accept_private_group_request, :destroy_group_request, :search_user_by_username, :post_notification]

  def all_groups
    respond_to do |format|
      @groups = Group.where(user_id: @user.id).order(created_at: :desc) if params[:q] == 'by-me'
      @groups = Group.includes(:user_groups).where(user_groups: {user_id: @user.id, request_accepted: true}).order(created_at: :desc) if params[:q] == 'where-am-member'
      @groups = Group.includes(:user_groups).order(created_at: :desc) if @groups.nil?
      format.json {render status: :ok}
    end
  end

  def search_user_by_username
    respond_to do |format|
      @users = User.where("lower(username) LIKE (?)", "%#{params[:username].downcase}%")
      format.json {render status: :ok}
    end
  rescue => exception
    respond_to do |format|
      format.json {
        render status: :unprocessable_entity,
        json: error_response_messages({error: [exception.message]})
      }
    end
  end

  def show_group
    @user_exists_in_group = current_user_group_member?(@group)
    if @user_exists_in_group and @user_exists_in_group.request_accepted
      respond_to do |format|
        format.json {render status: :ok}
        @users = @group.user_groups.order(created_at: :desc)
        # @posts = @group.posts.order(created_at: :desc)
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

  def group_members
    respond_to do |format|
      @members = @group.user_groups.where(request_accepted: true).order(updated_at: :asc) #.excluding(@user)
      format.json {render status: :ok}
    end
  end

  def group_user_requests
    respond_to do |format|
      @group_requests = @group.user_groups.where(request_accepted: false) #.order(created_at: :desc)#.excluding(@user)
      format.json {render status: :ok}
    end
  end

  def secret_group_invites
    respond_to do |format|
      @group_invites = @group.user_groups.where(secret_group_invitation: true) if @group.is_secret? #.order(created_at: :desc)#.excluding(@user)
      format.json {render status: :ok}
    end
  end

  def create
    @group = @user.groups.build(group_params)
    respond_to do |format|
      if @group.save
        ActionCable.server.broadcast "GroupsChannel", group_object(group: @group, action: 'create')
        format.json {render status: :ok}
      else
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages(@group.errors.messages)
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
    respond_to do |format|
      if @group.update(group_params)
        ActionCable.server.broadcast "GroupsChannel", group_object(group: @group, action: 'update')
        format.json {render status: :ok}
      else
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages(@group.errors.messages)
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

  def join_public_group
    user_exists_in_group = current_user_group_member?(@group)
    respond_to do |format|
      @user_group = UserGroup.new(is_member: true, group_id: @group.id, user_id: @user.id, request_accepted: true)
      if !user_exists_in_group && @group.is_public? && @user_group.save
        @group.update(total_members: @group.total_members + 1)
        ActionCable.server.broadcast "UsersGroupChannel", user_group_object(user_group: @user_group, action: 'create')
        ActionCable.server.broadcast "GroupsChannel", group_object(group: @group, action: 'update')
        format.json {render status: :ok}
      else
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [user_exists_in_group ? 'You already joined group.' : @user_group.errors.messages]})
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

  def request_to_join_private_group
    user_exists_in_group = current_user_group_member?(@group)
    respond_to do |format|
      @user_group = UserGroup.new(is_member: false, group_id: @group.id, user_id: @user.id, request_accepted: false)
      if !user_exists_in_group && @group.is_private? && @user_group.save
        ActionCable.server.broadcast "UsersGroupChannel", user_group_object(user_group: @user_group, action: 'create')
        ActionCable.server.broadcast "GroupsChannel", group_object(group: @group, action: 'update')
        format.json {render status: :ok}
      else
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [user_exists_in_group ? 'Request already sent.' : 'Request not sent. Try again.']})
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

  def invite_user_to_secret_group
    user = User.find_by_id(params[:user_id])
    user_exists_in_group = @group.user_groups.exists?(user_id: user.id)
    respond_to do |format|
      @user_group = UserGroup.new(is_member: true, group_id: @group.id, user_id: user.id, request_accepted: true, secret_group_invitation: true)
      if !user_exists_in_group && @group.is_secret? && @user_group.save
        @group.update(total_members: @group.total_members + 1)
        ActionCable.server.broadcast "UsersGroupChannel", user_group_object(user_group: @user_group, action: 'create')
        ActionCable.server.broadcast "GroupsChannel", group_object(group: @group, action: 'update')
        ActionCable.server.broadcast "NotificationsChannel", {message: "You have been invited to #{@group.name}", recipient: @user_group.user} # notification_object(message: "You have been invited to #{@group.name}", recipient: user, sender: @user, path: "group/#{@group.id}")
        format.json {render status: :ok}
      else
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [user_exists_in_group ? 'Already a member.' : 'Invitation not sent. Try again.']})
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

  def accept_private_group_request
    @user_group = UserGroup.find_by_id(params[:id])
    respond_to do |format|
      if @user_group.group.is_private? && @user_group.update(is_member: true, request_accepted: true)
        @user_group.group.update(total_members: @user_group.group.total_members + 1)
        ActionCable.server.broadcast "UsersGroupChannel", user_group_object(user_group: @user_group, action: 'update') # keep accept action
        ActionCable.server.broadcast "GroupsChannel", group_object(group: @user_group.group, action: 'update')
        format.json {render status: :ok}
      else
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [user_exists_in_group ? 'Request already accepted.' : 'Request not accepted. Try again.']})
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

  def destroy_group_request
    @user_group = UserGroup.find_by_id(params[:id])
    respond_to do |format|
      if @user_group.destroy
        @user_group.group.update(total_members: @user_group.group.total_members - 1)
        ActionCable.server.broadcast "UsersGroupChannel", user_group_object(user_group: @user_group, action: 'destroy')
        ActionCable.server.broadcast "GroupsChannel", group_object(group: @user_group.group, action: 'update')
        ActionCable.server.broadcast "NotificationsChannel", {message: "You have been removed from #{@user_group.group.name}.", recipient: @user_group.user}
        format.json {render status: :ok}
      else
        format.json {
          render status: :unprocessable_entity,
          json: error_response_messages({error: [user_exists_in_group ? 'Request already deleted.' : 'Request not deleted. Try again.']})
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

  def post_notification
    respond_to do |format|
    ActionCable.server.broadcast "NotificationsChannel", {message: "Notification posted", recipient: @user}
      format.json {render status: :ok}
    end
  end

  private
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

  def user_group_object(user_group:, action:)
    {
      id: user_group.id,
      is_member: user_group.is_member,
      is_admin: user_group.is_admin,
      request_accepted: user_group.request_accepted,
      group_id: user_group.group_id,
      user: user_group.user,
      user_id: user_group.user_id,
      action: action
    }
  end

  def notification_object(message:, recipient:, sender:, path:)
    {
      message: message,
      recipient: recipient,
      sender: sender,
      path: path
    }
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.permit(:name, :total_members, :total_posts, :group_access, :last_activity, :user_id)
  end
end
