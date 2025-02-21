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
end
