# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Followings", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "POST /api/v1/users/:user_id/follow" do
    it "follows a user" do
      expect {
        post "/api/v1/users/#{user.id}/follow", params: { followed_id: other_user.id }
      }.to change(Following, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(user.following?(other_user)).to be true
    end

    it "cannot follow self" do
      expect {
        post "/api/v1/users/#{user.id}/follow", params: { followed_id: user.id }
      }.not_to change(Following, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "cannot follow the same user twice" do
      user.follow(other_user)

      expect {
        post "/api/v1/users/#{user.id}/follow", params: { followed_id: other_user.id }
      }.not_to change(Following, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/users/:user_id/unfollow" do
    before { user.follow(other_user) }

    it "unfollows a user" do
      expect {
        delete "/api/v1/users/#{user.id}/unfollow", params: { followed_id: other_user.id }
      }.to change(Following, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(user.following?(other_user)).to be false
    end

    it "returns success even if not following the user" do
      another_user = create(:user)

      delete "/api/v1/users/#{user.id}/unfollow", params: { followed_id: another_user.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/users/:user_id/following" do
    before do
      create_list(:user, 3).each do |u|
        user.follow(u)
      end
    end

    it "returns the users being followed" do
      get "/api/v1/users/#{user.id}/following"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("users")
      expect(body["users"].length).to eq(3)
    end

    it "supports pagination" do
      get "/api/v1/users/#{user.id}/following", params: { page: 1, per_page: 2 }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["users"].length).to eq(2)
      expect(body["meta"]["current_page"]).to eq(1)
      expect(body["meta"]["total_pages"]).to eq(2)
    end
  end

  describe "GET /api/v1/users/:user_id/followers" do
    before do
      create_list(:user, 3).each do |u|
        u.follow(user)
      end
    end

    it "returns the followers" do
      get "/api/v1/users/#{user.id}/followers"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("users")
      expect(body["users"].length).to eq(3)
    end

    it "supports pagination" do
      get "/api/v1/users/#{user.id}/followers", params: { page: 1, per_page: 2 }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["users"].length).to eq(2)
      expect(body["meta"]["current_page"]).to eq(1)
      expect(body["meta"]["total_pages"]).to eq(2)
    end
  end
end
