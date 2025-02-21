# frozen_string_literal: true

module Api
  module V1
    class FollowingsController < ApplicationController
      before_action :set_user

      # POST /api/v1/users/:user_id/follow
      def follow
        followed = User.find(params[:followed_id])

        if @user.follow(followed)
          render json: { message: "Successfully followed user" }, status: :created
        else
          render json: { error: "Unable to follow user" }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:user_id/unfollow
      def unfollow
        followed = User.find(params[:followed_id])

        if @user.unfollow(followed)
          render json: { message: "Successfully unfollowed user" }, status: :ok
        else
          render json: { error: "Unable to unfollow user" }, status: :unprocessable_entity
        end
      end


      private

      def set_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
