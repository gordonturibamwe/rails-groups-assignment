Rails.application.routes.draw do
  root to: "welcome#welcome"

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      # User
      get "current-user", to: "user#current_user", as: 'current_user'
      post "user-registration", to: "user#user_registration", as: 'user_registration'
      post "user-login", to: "user#user_login"
      # get "verify-user-with-id/:verification_id", to: "user#verify_user_with_id"
      # patch "verify-user-with-otp", to: "user#verify_user_with_otp"
      # match "reset-user-password/:reset_password_id", to: "user#reset_user_password", as: 'reset_user_password', via: [:get, :post]
      patch "update-user", to: "user#update_user"
      patch "deactivate-user/:user_id", to: "user#deactivate_user"
      patch "activate-user/:user_id", to: "user#activate_user"
      patch "lock-user/:user_id", to: "user#lock_user"
      patch "unlock-user/:user_id", to: "user#unlock_user"
      # patch "update-user-roles/:user_id", to: "user#update_user_roles"
      # patch "remove-from-waitlist/:user_id", to: "user#remove_from_waitlist"
      # patch "add-to-waitlist/:user_id", to: "user#add_to_waitlist"
      # patch "reset-verification/:user_id", to: "user#reset_verification"
      delete "logout", to: "user#logout_user"
      # post "register-new-staff-user", to: "user#register_new_staff_user"
      # post "register-new-customer-user", to: "user#register_new_customer_user"

      # Communication
      post "send-sms", to: "send_messages#send_sms_now"
      post "send-email", to: "send_messages#send_email_now"
    end
  end

  # This stays at the last
  # match '*path', :to => "application#error_404"
  match '*path', to: 'errors#error_404', via: :all
end
