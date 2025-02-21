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
end
