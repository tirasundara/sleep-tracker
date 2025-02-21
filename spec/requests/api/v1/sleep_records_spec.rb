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
end
