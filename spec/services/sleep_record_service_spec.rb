# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SleepRecordService do
  describe '.following_sleep_records_from_previous_week' do
    let(:user) { create(:user) }
    let(:followed_user1) { create(:user) }
    let(:followed_user2) { create(:user) }
    let(:unfollowed_user) { create(:user) }

    before do
      # Set up following relationships
      user.follow(followed_user1)
      user.follow(followed_user2)

      # Create sleep records for the previous week
      @record1 = create(:sleep_record, :completed, user: followed_user1,
                       clock_in_at: 5.days.ago, clock_out_at: 5.days.ago + 8.hours, created_at: 5.days.ago)
      @record2 = create(:sleep_record, :completed, user: followed_user2,
                       clock_in_at: 3.days.ago, clock_out_at: 3.days.ago + 7.hours, created_at: 3.days.ago)
      @record3 = create(:sleep_record, :completed, user: followed_user1,
                       clock_in_at: 6.days.ago, clock_out_at: 6.days.ago + 9.hours, created_at: 6.days.ago)

      # Records that should not be included:
      # Old record (not from previous week)
      create(:sleep_record, :completed, user: followed_user1,
             clock_in_at: 2.weeks.ago, clock_out_at: 2.weeks.ago + 8.hours, created_at: 2.weeks.ago)

      # Active record (not completed)
      create(:sleep_record, user: followed_user2,
             clock_in_at: 5.hours.ago, clock_out_at: nil, status: :active, created_at: 5.hours.ago)

      # Record from unfollowed user
      create(:sleep_record, :completed, user: unfollowed_user,
             clock_in_at: 8.days.ago, clock_out_at: 8.days.ago + 5.hours, created_at: 8.days.ago)
    end

    it 'returns sleep records from followed users from the previous week' do

      result = SleepRecordService.following_sleep_records_from_previous_week(user)

      expect(result.count).to eq(3)

      # Should be ordered by duration (longest first)
      expect(result.to_a).to eq([ @record3, @record1, @record2 ])
    end

    it 'returns an empty collection if user follows nobody' do
      new_user = create(:user)
      result = SleepRecordService.following_sleep_records_from_previous_week(new_user)

      expect(result).to be_empty
    end
  end
end
