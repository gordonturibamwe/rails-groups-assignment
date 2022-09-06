class Api::V1::GroupsController < ApplicationController
  include Api::V1::GroupsHelper
  before_action :set_group, except: [:create, :all_groups]

  def all_groups
    respond_to do |format|
      @groups = Group.where(user_id: @user.id).order(created_at: :desc) if params[:q] == 'by-me'
      @groups = Group.includes(:user_groups).where(user_groups: {user_id: @user.id}).order(created_at: :desc) if params[:q] == 'where-am-member'
      @groups = Group.includes(:user_groups).order(created_at: :desc) if @groups.nil?
      format.json {render status: :ok}
    end
  end

  def show_group
    user_exists_in_group = current_user_group_member?(@group)
    if user_exists_in_group and user_exists_in_group.request_accepted
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


  def create
    @group = @user.groups.build(group_params)
    respond_to do |format|
      if @group.save
        # @group = @group.attributes.merge({action: 'create'}) @group
        ActionCable.server.broadcast "GroupsChannel", {
          id: @group.id,
          name: @group.name,
          group_access: @group.group_access,
          total_posts: @group.total_posts,
          total_members: @group.total_members,
          last_activity: @group.last_activity,
          user_id: @group.user_id,
          action: 'create'
        }
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

  private
  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.permit(:name, :total_members, :total_posts, :group_access, :last_activity, :user_id)
  end
end




# def index
#   @groups = Group.where(user_id: @user.id).order(created_at: :desc) if params[:q] == 'by-me'
#   @groups = Group.includes(:user_groups).where(user_groups: {user_id: current_user.id}).order(created_at: :desc) if params[:q] == 'where-am-member'
#   @groups = Group.includes(:user_groups).order(created_at: :desc) if @groups.nil?
# end

# def show
# end

# def show
#   user_exists_in_group = current_user_in_group(@group)
#   if user_exists_in_group.nil? || !user_exists_in_group.request_accepted
#     respond_to do |format|
#       format.turbo_stream {}
#     end
#   end
#   @users = @group.user_groups.order(created_at: :desc)
#   @posts = @group.posts.order(created_at: :desc)
# end

# def new
#   @group = current_user.groups.build
# end

# def edit
# end

# def update
#   if @group.update(group_params)
#     respond_to do |format|
#       format.turbo_stream {flash.now[:notice] = "Group was successfully created."}
#     end
#   else
#     render :edit, status: :unprocessable_entity
#   end
# end

# def destroy
#   @group.destroy
#   respond_to do |format|
#     format.json { head :no_content }
#   end
# end

# def join_group
#   user_exists_in_group = current_user_in_group(@group)
#   if !user_exists_in_group && @group.is_public? && UserGroup.create(is_member: true, group_id: @group.id, user_id: current_user.id, request_accepted: true)
#     @group.update(total_members: @group.total_members + 1)
#     respond_to do |format|
#       flash.now[:notice] = "You have joined #{@group.name}"
#     end
#   else
#     respond_to do |format|
#       format.turbo_stream {flash.now[:notice] = "You already a member."}
#     end
#   end
# end

# def request_to_join_group
#   if @group.is_private? && UserGroup.create(is_member: true, group_id: @group.id, user_id: current_user.id, request_accepted: false)
#     respond_to do |format|
#       format.turbo_stream {render turbo_stream: turbo_stream.replace(@group)}
#     end
#   end
# end

# def decline_group_request
#   respond_to do |format|
#     if @group.is_private? && UserGroup.create(request_accepted: false, request_declined: true)
#       format.json { render :show, status: :ok, location: @group }
#     else
#       format.json { render json: @group.errors, status: :unprocessable_entity }
#     end
#   end
# end

# def approve_group_request
#   respond_to do |format|
#     if @group.user == current_user && @group.user_groups.find_by(user_id: params[:user_id]).update(request_accepted: true)
#       @group.update(total_members: @group.total_members + 1)
#       format.html { redirect_to show_group_url(@group), notice: "Join #{@group.name} group was successfully updated." }
#       format.json { render :show, status: :ok, location: @group }
#     else
#       format.html { render :edit, status: :unprocessable_entity }
#       format.json { render json: @group.errors, status: :unprocessable_entity }
#     end
#   end
# end

# def remove_user_from_group_request
#   respond_to do |format|
#     if @group.user == current_user && @group.user_groups.find_by(user_id: params[:user_id]).destroy
#       @group.update(total_members: @group.total_members - 1)
#       format.html { redirect_to show_group_url(@group), notice: "Join #{@group.name} group was successfully updated." }
#       format.json { render :show, status: :ok, location: @group }
#     else
#       flash[:notice] = 'Not authorized.'
#       redirect_to authenticated_root_path
#     end
#   end
# end

# def invite_user_to_group
# end
