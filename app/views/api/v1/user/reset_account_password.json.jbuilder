json.security_question @security_question.security_question
json.user_locked_on @user.user_locked_on
json.reset_password_expiration @user.reset_password_expiration if !@user.reset_password_token.nil?
