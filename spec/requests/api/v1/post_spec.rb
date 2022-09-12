require 'rails_helper'

RSpec.describe "Api::V1::Posts", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/api/v1/post/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/api/v1/post/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /all_posts" do
    it "returns http success" do
      get "/api/v1/post/all_posts"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show_post" do
    it "returns http success" do
      get "/api/v1/post/show_post"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/api/v1/post/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
