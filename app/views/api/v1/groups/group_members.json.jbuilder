json.members @members.each do |member|
  json.id member.id
  json.user_id member.group.user_id
  json.user member.user
  json.is_admin member.is_admin
  json.is_member member.is_member
  json.request_accepted member.request_accepted
end
