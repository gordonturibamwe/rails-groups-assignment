json.invites @group_invites.each do |group_invites|
  json.id group_invites.id
  json.user_id group_invites.group.user_id
  json.user group_invites.user
  json.is_admin group_invites.is_admin
  json.is_member group_invites.is_member
  json.request_accepted group_invites.request_accepted
end
