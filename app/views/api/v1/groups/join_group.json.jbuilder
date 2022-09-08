json.id @group.id
json.name @group.name
json.group_access @group.group_access
json.total_posts @group.total_posts
json.total_members @group.total_members
json.last_activity @group.last_activity
json.user_id @group.user_id
json.user_exists_in_group group.user_groups.find_by_user_id(@user.id)
