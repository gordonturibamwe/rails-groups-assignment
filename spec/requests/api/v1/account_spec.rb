require 'rails_helper'
RSpec.describe "Api::V1::UserController", type: :request do
  ################################
  # TESTING ACCOUNT REGISTRATION
  describe 'Registration process' do
    it "user_registration ::: Shows attributes missing errors" do
      post '/api/v1/user-registration'#, format: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include("Phone number or email and password are required.")
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end

    it "user_registration ::: Shows User roles is missing errors" do
      params = {phone_number: '+256753020159',email: 'crafri.com@gmail.com'}
      post '/api/v1/user-registration', params: params
      expect(JSON.parse(response.body)['errors']).to include("User roles missing.")
    end

    it "user_registration ::: Shows Password is missing errors" do
      params = {phone_number: '+256753020159',email: 'crafri.com@gmail.com',roles: 'business-api,employer,employee'}
      post '/api/v1/user-registration', params: params
      expect(JSON.parse(response.body)['errors']).to include("Password is missing.")
    end

    it "user_registration ::: Registers User" do
      params = {phone_number: '+256753020159',email: 'crafri.com@gmail.com',roles: 'business-api,employer,employee',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      expect(response).to have_http_status(:ok)
    end

    it "user_registration ::: Registering should return token in headers" do
      params = {phone_number: '+256753020159',email: 'crafri.com@gmail.com',roles: 'business-api,employer,employee',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      expect(response.headers["X-Auth-Token"]).not_to eq(nil)
    end

    it "user_registration ::: Registering should return json data" do
      params = {phone_number: '+256753020159',email: 'crafri.com@gmail.com',roles: 'business-api,employer,employee',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      data = JSON.parse(response.body)
      expect(data['month']).to eq(DateTime.now.month)
      expect(data['is_superuser']).to be_falsey
      expect(data['is_staff']).to be_falsey
      expect(data['staff_roles']).to match_array([])
      expect(data['customer_roles']).to include('employer')
      expect(data['user_verification_id']).to be_truthy
      expect(data['user_verification_sent_to']).to match_array([params[:phone_number], params[:email]])
      expect(data['security_question_setup_id']).to be_truthy
    end

    it "user_registration ::: Staff roles not allowed to be registered using external registration" do
      params = {phone_number: '+256753020159',email: 'crafri.com@gmail.com',roles: 'staff, admin, superuser',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "user_registration ::: User registration should log activity in user_log" do
      params = {phone_number: '+256753020159',email: 'crafri.com@gmail.com',roles: 'employee',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      user = User.find_by(phone_number: params[:phone_number])
      expect(user.user_logs.count).to be > 0
    end
  end

  ################################
  # TESTING ACCOUNT LOGIN
  describe 'Login process' do
    before(:context) do
      user = User.create!(
        phone_number: '+16175806322',
        password: '111111',
        is_superuser: true,
        is_staff: true,
        staff_roles: ['super-user','super-admin'],
        is_user_verified: true,
        is_on_waitlist: false,
        is_user_verified: true
      )
      params = {phone_number: '+255888888',email: 'g4@g4.com',roles: 'business-api,employer,employee',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      $response = response
    end

    after(:all) do
      User.destroy_all  # Cleanup all models and their automatically created associations like tags
    end

    it "Shows attributes missing errors" do
      post '/api/v1/user-login'
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include("Phone_number or email and password are required.")
      expect(response.content_type).to eq("application/json; charset=utf-8")
    end

    it "user_login ::: Shows User does not exist" do
      params = {phone_number: '+2567530201595',password: '111111'}
      post '/api/v1/user-login', params: params
      expect(JSON.parse(response.body)['errors']).to include("User with provided logins does not exist.")
    end

    it "user_login ::: Verify user requirement" do
      params = {phone_number: '+255888888',password: '111111'}
      post '/api/v1/user-login', params: params
      data = JSON.parse(response.body)
      expect(data['errors']).to include("User not yet verified. Verification link or short code was sent to your contacts you registered with.")
    end

    it "reset_verification ::: User verification with ID should return status :ok" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)
    end

    it "reset_verification ::: User verification with OTP should return status :ok" do
      data = JSON.parse($response.body)
      patch "/api/v1/verify-user-with-otp", params: {otp: data['user_verification_otp']}, headers: {'Authorization': "Bearer #{$response.headers["X-Auth-Token"]}"}
      expect(response).to have_http_status(:ok)
    end

    it "user_login ::: Show User login status :ok" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      post '/api/v1/user-login', params: {phone_number: '+255888888',password: '111111'}
      data = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
    end

    it "user_login ::: User login should return token in headers" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      post '/api/v1/user-login', params: {phone_number: '+255888888',password: '111111'}
      data = JSON.parse(response.body)
      expect(response.headers["X-Auth-Token"]).not_to be(nil)
    end

    it "user_login ::: Valid token should match Bearer token" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      params = {phone_number: '+255888888',password: '111111'}
      post '/api/v1/user-login', params: params
      data = JSON.parse(response.body)
      user = User.find_by(phone_number: params[:phone_number])
      expect(response.headers["X-Auth-Token"].split('.')[2]).to eq(user.valid_token)
    end

    it "user_login ::: New user login should have empty security question and answer" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      params = {phone_number: '+255888888',password: '111111'}
      post '/api/v1/user-login', params: params
      data = JSON.parse(response.body)
      user = User.find_by(phone_number: params[:phone_number])
      expect(user.security_question).to be_truthy
      expect(user.security_question.security_question).to eq(nil)
      expect(user.security_question.security_answer).to eq(nil)
      expect(user.security_question.security_question_setup_id).to be_truthy
    end

    it "user_login ::: User login should return json data" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      params = {phone_number: '+255888888',password: '111111'}
      post '/api/v1/user-login', params: params
      data = JSON.parse(response.body)
      expect(data['is_superuser']).to be_falsey
      expect(data['is_staff']).to be_falsey
      expect(data['staff_roles']).to be_falsey
      expect(data['customer_roles']).to include('employer')
      expect(data['user_verification_id']).to be_falsey
      expect(data['user_verification_sent_to']).to match_array([])
      expect(data['is_security_question_setup']).to be_falsey
    end

    it "user_login ::: 6 failed login attempts lock user" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      params = {phone_number: '+255888888',password: 'wrong_password'}
      6.times do |t|
        post '/api/v1/user-login', params: params
      end
      post '/api/v1/user-login', params: params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include('User is locked.')
    end

    it "reset_user_password ::: Security question required to reset user password" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      params = {phone_number: '+255888888',password: 'wrong_password'}
      6.times do |t|
        post '/api/v1/user-login', params: params
      end
      user = User.find_by(phone_number: params[:phone_number])
      new_params = {security_question: 'sss', security_answer: 'Fine', password: '123456', repeat_password: '123456'}
      post "/api/v1/reset-user-password/#{user.reset_password_id}", params: new_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include('You do not have security question setup. Please contact support team for help.')
    end

    it "reset_user_password ::: Reset locked user after failed login attempts" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      params = {phone_number: '+255888888',password: 'wrong_password'}
      6.times do |t|
        post '/api/v1/user-login', params: params
      end
      user = User.find_by(phone_number: params[:phone_number])
      new_params = {security_question: 'sss', security_answer: 'Fine'}
      post "/api/v1/setup-security-question/#{JSON.parse($response.body)['security_question_setup_id']}", params: new_params
      expect(response).to have_http_status(:ok)

      user = User.find_by(phone_number: '+255888888')
      new_params = {security_question: 'sss', security_answer: 'Fine', password: '444444', repeat_password: '444444'}
      post "/api/v1/reset-user-password/#{user.reset_password_id}", params: new_params

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['success']).to include('User password reset successfully.')

      params = {phone_number: '+255888888',password: '444444'}
      post '/api/v1/user-login', params: params
      expect(response).to have_http_status(:ok)
    end

    it "update_user ::: User update information" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      params = {phone_number: '+255888888',password: '111111'}
      post '/api/v1/user-login', params: params
      token = response.headers["X-Auth-Token"]
      user_id = JSON.parse(response.body)['id']
      expect(response).to have_http_status(:ok)

      user_info_to_update = {username: 'gordon', email: 'turix@outlook.com', number: '2557222222'}
      patch "/api/v1/update-user", params: user_info_to_update, headers: {'Authorization': "Bearer #{token}"}
      expect(response).to have_http_status(:ok)
    end

    it "update_user ::: Staff update customers information" do
      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      customer_user = User.find_by(phone_number: '+255888888')
      customer_info_to_update = {user_id: customer_user.id, username: 'gordon', email: 'turix@outlook.com', number: '2557222222'}
      patch "/api/v1/update-user", params: customer_info_to_update, headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
    end

    it "deactivate_user ::: Staff deactivate another user's user" do
      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      customer_user = User.find_by(phone_number: '+255888888')
      patch "/api/v1/deactivate-user/#{customer_user.id}", headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
      customer_user = User.find_by(phone_number: '+255888888')
      expect(customer_user['is_user_active']).to be_falsey
    end

    it "activate_user ::: Staff activate another user's user" do
      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      customer_user = User.find_by(phone_number: '+255888888')
      patch "/api/v1/activate-user/#{customer_user.id}", headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
      customer_user = User.find_by(phone_number: '+255888888')
      expect(customer_user['is_user_active']).to be_truthy
    end

    it "remove_from_waitlist ::: Staff remove another user's user from waitlist" do
      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      customer_user = User.find_by(phone_number: '+255888888')
      patch "/api/v1/remove-from-waitlist/#{customer_user.id}", headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
      customer_user = User.find_by(phone_number: '+255888888')
      expect(customer_user['is_on_waitlist']).to be_falsey
    end

    it "add_to_waitlist ::: Staff add another user's user to waitlist" do
      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      customer_user = User.find_by(phone_number: '+255888888')
      patch "/api/v1/add-to-waitlist/#{customer_user.id}", headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
      customer_user = User.find_by(phone_number: '+255888888')
      expect(customer_user['is_on_waitlist']).to be_truthy
    end

    it "lock_user ::: Staff lock another user's user" do
      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      customer_user = User.find_by(phone_number: '+255888888')
      patch "/api/v1/lock-user/#{customer_user.id}", headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
      customer_user = User.find_by(phone_number: '+255888888')
      expect(customer_user['is_user_locked']).to be_truthy
    end

    it "unlock_user ::: Staff unlock another user's user" do
      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      customer_user = User.find_by(phone_number: '+255888888')
      patch "/api/v1/unlock-user/#{customer_user.id}", headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
      customer_user = User.find_by(phone_number: '+255888888')
      expect(customer_user['is_user_locked']).to be_falsey
    end

    it "logout_user ::: Logged in user should logout" do
      get "/api/v1/verify-user-with-id/#{JSON.parse($response.body)['user_verification_id']}"
      expect(response).to have_http_status(:ok)

      params = {phone_number: '+255888888',password: '111111'}
      post '/api/v1/user-login', params: params
      data = JSON.parse(response.body)
      user = User.find_by(phone_number: params[:phone_number])
      token = response.headers["X-Auth-Token"]
      expect(token.split('.')[2]).to eq(user.valid_token)

      delete '/api/v1/logout', headers: {'Authorization': "Bearer #{token}"}
      data = JSON.parse(response.body)
      user = User.find_by(phone_number: params[:phone_number])
      expect(response).to have_http_status(:ok)
      expect(response.headers["X-Auth-Token"]).to eq(nil)
      expect(user.valid_token).to eq("")
    end

  end


  ################################
  # TESTING STAFF REGISTER ANOTHER ACCOUNT
  describe "a specification" do
    before(:context) do
      User.create!(
        phone_number: '+16175806322',
        password: '111111',
        is_superuser: true,
        is_staff: true,
        staff_roles: ['super-user','super-admin'],
        is_user_verified: true,
        is_on_waitlist: false,
        is_user_verified: true
      )
    end

    after(:all) do
      User.destroy_all  # Cleanup all models and their automatically created associations like tags
    end

    it "register_new_staff_user ::: Register new customer user" do
      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      new_customer_params = {
        phone_number: '97812345678',
        email: '1@1.com',
        password: '111111',
        roles: 'employer,employee'
      }
      post '/api/v1/register-new-customer-user', params: new_customer_params, headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
      new_user = User.find_by(phone_number: '+97812345678')
      expect(new_user.is_superuser).to be_falsey
      expect(new_user.is_staff).to be_falsey
      expect(new_user.staff_roles).to eq([])
      expect(new_user.customer_roles).to include('employer')
      expect(new_user.verification_id).to be_truthy
      expect(new_user.security_question).to be_truthy
    end

    it "register_new_staff_user ::: Register new staff user" do
      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      new_staff = {
        phone_number: '444444444',
        email: '2@2.com',
        password: '111111',
        roles: 'super-admin'
      }
      post '/api/v1/register-new-staff-user', params: new_staff, headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
      new_user = User.find_by(phone_number: '+444444444')
      expect(new_user.is_superuser).to be_falsey
      expect(new_user.is_staff).to be_truthy
      expect(new_user.customer_roles).to eq([])
      expect(new_user.staff_roles).to include('super-admin')
      expect(new_user.verification_id).to be_truthy
      expect(new_user.security_question).to be_truthy
    end
  end
end
