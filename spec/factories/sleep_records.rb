# frozen_string_literal: true

FactoryBot.define do
  factory :sleep_record do
    user
    clock_in_at { Time.current }

    trait :completed do
      clock_out_at { clock_in_at + 8.hours }
      status { :completed }
      duration { 480 * 60 } # 8 hours in seconds
    end

    trait :auto_completed do
      clock_out_at { clock_in_at + 8.hours }
      status { :auto_completed }
      duration { 480 * 60 } # 8 hours in seconds
    end
  end
end
