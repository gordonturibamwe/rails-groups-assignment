require 'rails_helper'

RSpec.describe "Api::V1::SendMessages", type: :request do
  describe "POST /send_sms" do
    it "returns http success" do
      post "/api/v1/send-sms", params: {phone_number: '+256755055811', message: 'Testing this message'}
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /send_email" do
    it "returns http success" do
      post "/api/v1/send-email", params: {email: 'crafri.com@gmail.com', message: 'Testing this message'}
      puts JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
    end
  end

end
