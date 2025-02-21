require "sidekiq/web"

Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq Web UI  -- for production, we should use an authentication
  mount Sidekiq::Web => "/sidekiq"

  namespace :api do
    namespace :v1 do
      resources :users, only: [] do
        resources :sleep_records, only: [ :index ] do
          collection do
            post :clock_in # clock in a sleep record
          end
          member do
            patch :clock_out # clock out a sleep record
          end
        end

        get :following_sleep_records, to: "sleep_records#following_sleep_records" # get following users' sleep records

        # follow-unfollow routes
        post :follow, to: "followings#follow"         # follow a user
        delete :unfollow, to: "followings#unfollow"   # unfollow a user
        get :following, to: "followings#following"    # get following users
        get :followers, to: "followings#followers"    # get followers
      end
    end
  end
end
