json.users @users.each do |user|
  json.id user.id
  json.username user.username
end
