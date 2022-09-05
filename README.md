# Rails-Auth
### User
Create user with either
  - `phone_number` ~ valid phone number (optional if email is provided)
  - `email` ~ valid email address (optional if phone_number is provided)
  - `password` ~ required to create user
### SecurityQuestion
Setup security question after user registration
  - `security_question` ~ required when setting or updating security question
  - `security_answer` ~ required when setting or updating security question
### UserLogs
User logs logs every action that happens on user and security question.
  - `description` ~ what happened explained
  - `action` ~ which controller_action action happened
  - `action_controller` ~ which controller action happened
  - `action_by` ~ user_id
  - `user_on` ~ user_id

### Routes
```
post "/api/v1//user-registration"
post "/api/v1/user-login"
get "/api/v1/verify-user-with-id/:verification_id"
patch "/api/v1/verify-user-with-otp"
get "/api/v1/reset-user-password/:reset_password_id"
post "/api/v1/reset-user-password/:reset_password_id"
patch "/api/v1/update-user"
patch "/api/v1/deactivate-user/:user_id"
patch "/api/v1/activate-user/:user_id"
patch "/api/v1/lock-user/:user_id"
patch "/api/v1/unlock-user/:user_id"
patch "/api/v1/update-user-roles/:user_id"
patch "/api/v1/remove-from-waitlist/:user_id"
patch "/api/v1/add-to-waitlist/:user_id"
patch "/api/v1/reset-verification/:user_id"
delete "/api/v1/logout"
post "/api/v1/register-new-staff-user"
post "/api/v1/register-new-customer-user"

# Security Question
post "/api/v1/setup-security-question/:security_question_setup_id"
patch "/api/v1/update-security-question"
patch "/api/v1/reset-security-question/:user_id"
delete "delete-security-question/:user_id"

# Communication
post "/api/v1/send-sms"
post "/api/v1/send-email"

```

