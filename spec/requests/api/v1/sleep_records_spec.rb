require 'rails_helper'

RSpec.describe "Api::V1::SleepRecords", type: :request do
  let(:user) { create(:user) }

  describe "POST /api/v1/users/:user_id/sleep_records/clock_in" do
    context "when user has no active sleep record" do
      it "creates a new sleep record" do
        expect {
          post "/api/v1/users/#{user.id}/sleep_records/clock_in"
        }.to change(SleepRecord, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key("sleep_record")
        expect(JSON.parse(response.body)["sleep_record"]).to include("id", "clock_in_at", "status")
      end
    end

    context "when user already has an active sleep record" do
      before { create(:sleep_record, user: user) }

      it "returns an error" do
        expect {
          post "/api/v1/users/#{user.id}/sleep_records/clock_in"
        }.not_to change(SleepRecord, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to include("You already have an active sleep record")
      end
    end
  end

  describe "PATCH /api/v1/users/:user_id/sleep_records/:id/clock_out" do
    context "with an active sleep record" do
      let!(:sleep_record) { create(:sleep_record, user: user) }

      it "clocks out the sleep record" do
        patch "/api/v1/users/#{user.id}/sleep_records/#{sleep_record.id}/clock_out"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to have_key("sleep_record")
        expect(JSON.parse(response.body)["sleep_record"]["status"]).to eq("completed")
        expect(JSON.parse(response.body)["sleep_record"]["clock_out_at"]).not_to be_nil
      end
    end

    context "without an active sleep record" do
      it "returns an error" do
        patch "/api/v1/users/#{user.id}/sleep_records/1/clock_out"

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)["error"]).to include("No active sleep record found")
      end
    end
  end

  describe "GET /api/v1/users/:user_id/sleep_records" do
    before do
      create(:sleep_record, user: user, clock_in_at: 1.day.ago, created_at: 1.day.ago, clock_out_at: 1.day.ago, status: "completed")
      create(:sleep_record, user: user, clock_in_at: 2.days.ago, created_at: 2.days.ago, clock_out_at: 2.days.ago, status: "completed")
      create(:sleep_record, user: user, clock_in_at: 3.days.ago, created_at: 3.days.ago, clock_out_at: 3.days.ago, status: "completed")
      create(:sleep_record, user: user, clock_in_at: 4.days.ago, created_at: 4.days.ago, clock_out_at: 4.days.ago, status: "completed")
      create(:sleep_record, user: user, clock_in_at: Time.current, created_at: Time.current, clock_out_at: nil, duration: 0, status: "active")
    end

    it "returns the user's sleep records" do
      get "/api/v1/users/#{user.id}/sleep_records"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("sleep_records")
      expect(body["sleep_records"].length).to eq(5)
      expect(body).to have_key("meta")
      expect(body["meta"]).to include("current_page", "total_pages")
    end

    it "supports pagination" do
      get "/api/v1/users/#{user.id}/sleep_records", params: { page: 1, per_page: 2 }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["sleep_records"].length).to eq(2)
      expect(body["meta"]["current_page"]).to eq(1)
    end
  end

  describe "GET /api/v1/users/:user_id/following_sleep_records" do
    let(:followed_user1) { create(:user) }
    let(:followed_user2) { create(:user) }

    before do
      # follow the followed users
      create(:following, follower: user, followed: followed_user1)
      create(:following, follower: user, followed: followed_user2)

      # Create sleep records for the followed users from the previous week
      create(:sleep_record, :completed, user: followed_user1, clock_in_at: 5.days.ago, clock_out_at: 5.days.ago + 8.hours, created_at: 5.days.ago)
      create(:sleep_record, :completed, user: followed_user2, clock_in_at: 3.days.ago, clock_out_at: 3.days.ago + 7.hours, created_at: 3.days.ago)

      # Create an old sleep records (not from previous week)
      create(:sleep_record, :completed, user: followed_user1, clock_in_at: 2.weeks.ago, created_at: 2.weeks.ago)
      create(:sleep_record, :completed, user: followed_user2, clock_in_at: 3.weeks.ago, created_at: 3.weeks.ago)
    end

    it "returns sleep records from followed users from the previous week" do
      get "/api/v1/users/#{user.id}/following_sleep_records"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to have_key("sleep_records")
      expect(body["sleep_records"].length).to eq(2)

      # Should be ordered by duration (longest first)
      expect(body["sleep_records"][0]["duration"]).to eq(28800)
      expect(body["sleep_records"][1]["duration"]).to eq(25200)

      # Each record should include the user
      expect(body["sleep_records"][0]).to have_key("user")
      expect(body["sleep_records"][0]["user"]).to have_key("name")
    end

    it "supports pagination" do
      get "/api/v1/users/#{user.id}/following_sleep_records", params: { page: 1, per_page: 1 }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["sleep_records"].length).to eq(1)
      expect(body["meta"]["current_page"]).to eq(1)
      expect(body["meta"]["total_pages"]).to eq(2)
    end
  end
end
