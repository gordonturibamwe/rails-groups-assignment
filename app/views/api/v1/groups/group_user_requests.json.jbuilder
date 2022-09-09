json.group_requests @group_requests.each do |group_request|
  json.id group_request.id
  json.user_id group_request.group.user_id
  json.user group_request.user
  json.is_admin group_request.is_admin
  json.is_member group_request.is_member
  json.request_accepted group_request.request_accepted
end
