Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  root to: "welcome#welcome"

  namespace :api, defaults: {format: :json} do # Users
    namespace :v1 do
      get "current-user", to: "user#current_user", as: 'current_user'
      post "user-registration", to: "user#user_registration", as: 'user_registration'
      post "user-login", to: "user#user_login"
      patch "update-user", to: "user#update_user"
      patch "deactivate-user/:user_id", to: "user#deactivate_user"
      patch "activate-user/:user_id", to: "user#activate_user"
      patch "lock-user/:user_id", to: "user#lock_user"
      patch "unlock-user/:user_id", to: "user#unlock_user"
      delete "logout", to: "user#logout_user"

      # Communication
      post "send-sms", to: "send_messages#send_sms_now"
      post "send-email", to: "send_messages#send_email_now"
    end
  end

  namespace :api, defaults: {format: :json} do # Groups
    namespace :v1 do
      get 'all-groups', to: 'groups#all_groups'
      get 'search-user/:username', to: 'groups#search_user_by_username'
      get 'group/:id', to: 'groups#show_group'
      get 'group/:id/members', to: 'groups#group_members'
      get 'group/:id/user-requests', to: 'groups#group_user_requests'
      get 'group/:id/secret-group-invites', to: 'groups#secret_group_invites'
      post 'create-group', to: 'groups#create'
      match 'update-group/:id', to: 'groups#update', via: ['post', 'patch']
      post 'join-public-group/:id', to: 'groups#join_public_group'
      post 'invite-user-to-secret-group/:id/user/:user_id', to: 'groups#invite_user_to_secret_group'
      post 'request-to-join-private-group/:id', to: 'groups#request_to_join_private_group'
      patch 'accept-private-group-request/:id', to: 'groups#accept_private_group_request'
      delete 'destroy-group-request/:id', to: 'groups#destroy_group_request'
    end
  end

  namespace :api, defaults: {format: :json} do # Posts
    namespace :v1 do
      post 'create-post', to: 'post#create'
      post 'post/create'
      get 'post/destroy'
      get 'post/all_posts'
      get 'post/show_post'
      get 'post/edit'
    end
  end


  # This stays at the last
  # match '*path', :to => "application#error_404"
  match '*path', to: 'errors#error_404', via: :all
end
