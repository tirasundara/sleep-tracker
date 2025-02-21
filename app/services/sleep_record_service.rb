class SleepRecordService
  def self.following_sleep_records_from_previous_week(user)
    # Get IDs of users being followed
    following_ids = user.following.pluck(:id)
    return SleepRecord.none if following_ids.empty?

    # Get sleep records from previous week, completed only, ordered by duration
    SleepRecord.includes(:user)
               .where(user_id: following_ids)
               .completed
               .from_previous_week
               .ordered_by_duration
  end
end
