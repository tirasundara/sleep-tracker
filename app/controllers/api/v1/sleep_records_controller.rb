# frozen_string_literal: true

module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_user

      # POST /api/v1/users/:user_id/sleep_records/clock_in
      def clock_in
        sleep_record = @user.sleep_records.new(clock_in_at: Time.current)

        if sleep_record.save
          render json: sleep_record, status: :created
        else
          render json: { errors: sleep_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
