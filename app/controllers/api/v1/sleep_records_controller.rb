# frozen_string_literal: true

module Api
  module V1
    class SleepRecordsController < ApplicationController
      before_action :set_user
      before_action :set_sleep_record, only: [ :clock_out ]

      # POST /api/v1/users/:user_id/sleep_records/clock_in
      def clock_in
        sleep_record = @user.sleep_records.new(clock_in_at: Time.current)

        if sleep_record.save
          render json: sleep_record, status: :created
        else
          render json: { errors: sleep_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/users/:user_id/sleep_records/:id/clock_out
      def clock_out
        if @sleep_record.clock_out!
          render json: @sleep_record
        else
          render json: { error: "Cannot clock out. No active sleep record found." }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/users/:user_id/sleep_records
      def index
        sleep_records = @user.sleep_records.ordered_by_created_at.page(params[:page]).per(params[:per_page])

        render json: sleep_records, meta: pagination_meta(sleep_records), each_serializer: SleepRecordSerializer
      end

      # GET /api/v1/users/:user_id/following_sleep_records
      def following_sleep_records
        sleep_records = SleepRecordService.following_sleep_records_from_previous_week(@user).page(params[:page]).per(params[:per_page])

        render json: sleep_records, meta: pagination_meta(sleep_records), each_serializer: SleepRecordWithUserSerializer
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end

      def set_sleep_record
        @sleep_record = @user.active_sleep_record

        unless @sleep_record
          render json: { error: "No active sleep record found" }, status: :not_found
        end
      end
    end
  end
end
