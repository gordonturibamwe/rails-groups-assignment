require 'rails_helper'

RSpec.describe "Api::V1::SecurityQuestions", type: :request do
  describe 'Security Questions' do
    before(:context) do
      $user = User.create!(
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

    it "setup_security_question ::: Creating new user creates security_question" do
      params = {phone_number: '+255755811',email: 'g@g.com',roles: 'business-api,employer,employee',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      expect(response).to have_http_status(:ok)

      user = User.find_by_phone_number(params[:phone_number])
      expect(user.security_question.security_question).to eq(nil)
      expect(user.security_question.security_answer).to eq(nil)
      expect(user.security_question.security_question_setup_id).to be_truthy
      expect(user.security_question).to be_truthy
    end

    it "setup_security_question ::: Setting up security question after creating new user" do
      params = {phone_number: '+255755811',email: 'g@g.com',roles: 'business-api,employer,employee',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      security_question_setup_id = JSON.parse(response.body)['security_question_setup_id']
      expect(response).to have_http_status(:ok)

      new_params = {security_question: 'Security Question', security_answer: 'Fine'}
      post "/api/v1/setup-security-question/#{security_question_setup_id}", params: new_params
      expect(response).to have_http_status(:ok)
      user = User.find_by_phone_number(params[:phone_number])
      expect(user.security_question.security_question).to eq('Security Question')
      expect(user.security_question.security_answer).to eq('Fine')
      expect(user.security_question.security_question_setup_id).to eq(nil)
      expect(user.security_question).to be_truthy
    end

    it "update_security_question ::: Updating security question after creating new user" do
      params = {phone_number: '+255755811',email: 'g@g.com',roles: 'business-api,employer,employee',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      data = JSON.parse(response.body)
      token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      new_params = {security_question: 'Changed thisssss', security_answer: 'Finesssssss'}
      patch "/api/v1/update-security-question/", params: new_params, headers: {'Authorization': "Bearer #{token}"}
      expect(response).to have_http_status(:ok)
      user = User.find_by_phone_number(params[:phone_number])
      expect(user.security_question.security_question).to eq('Changed thisssss')
      expect(user.security_question.security_answer).to eq('Finesssssss')
      expect(user.security_question.security_question_setup_id).to eq(nil)
      expect(user.security_question).to be_truthy
    end

    it "reset_security_question ::: Staff reset other user's security_question" do
      params = {phone_number: '+255755811',email: 'g@g.com',roles: 'business-api,employer,employee',password: '111111',repeat_password: '111111'}
      post '/api/v1/user-registration', params: params
      data = JSON.parse(response.body)
      token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      staff_params = {phone_number: '+16175806322',password: '111111'}
      post '/api/v1/user-login', params: staff_params
      staff_token = response.headers["X-Auth-Token"]
      expect(response).to have_http_status(:ok)

      patch "/api/v1/reset-security-question/#{data['id']}", headers: {'Authorization': "Bearer #{staff_token}"}
      expect(response).to have_http_status(:ok)
    end
  end
end
