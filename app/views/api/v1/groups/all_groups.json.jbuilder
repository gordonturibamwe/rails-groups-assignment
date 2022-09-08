json.groups @groups.each do |group|
  json.id group.id
  json.name group.name
  json.group_access group.group_access
  json.total_posts group.total_posts
  json.total_members group.total_members
  json.last_activity group.last_activity
  json.user_id group.user_id
  json.user_exists_in_group group.user_groups.find_by_user_id(@user.id)
end



  # @user.groups.user_groups
  # @group.user_groups
  # @group.user_groups
  # if group.user_groups.include?(@user.id)
  #   json.user_exists_in_group do
  #     json.is_admin @user_exists_in_group.is_admin
  #     json.is_member @user_exists_in_group.is_member
  #     json.request_accepted @user_exists_in_group.request_accepted
  #   end
  # else
  #   json.user_exists_in_group false
  # end



  # json.user_exists_in_group do

  # end@groups.first.user_groups.include?(@user.id)
