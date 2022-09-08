json.id @group.id
json.name @group.name
json.group_access @group.group_access
json.total_posts @group.total_posts
json.total_members @group.total_members
json.last_activity @group.last_activity
json.user_id @group.user_id
json.action 'created'
if @user_exists_in_group
  json.user_exists_in_group do
    json.is_admin @user_exists_in_group.is_admin
    json.is_member @user_exists_in_group.is_member
    json.request_accepted @user_exists_in_group.request_accepted
  end
else
  json.user_exists_in_group false
end
