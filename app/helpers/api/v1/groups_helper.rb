module Api::V1::GroupsHelper
  def current_user_group_member?(group)
    group.user_groups.detect {|user_group| user_group.user_id == @user.id}
  end
end
