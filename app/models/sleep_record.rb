# frozen_string_literal: true

class SleepRecord < ApplicationRecord
  DEFAULT_DURATION = 8.hours
  AUTO_COMPLETE_THRESHOLD = 12.hours

  belongs_to :user

  enum status: { active: 0, completed: 1, auto_completed: 2 }

  validates :clock_in_at, presence: true
  validate :no_active_sleep_record, on: :create
  validate :clock_out_after_clock_in, if: -> { clock_out_at.present? }

  scope :ordered_by_created_at, -> { order(created_at: :desc) }
  scope :ordered_by_duration, -> { order(duration: :desc) }
  scope :completed, -> { where.not(status: :active) }
  scope :from_previous_week, -> {
    where(created_at: 1.week.ago.in_time_zone.beginning_of_day..Time.current)
  }

  after_save :calculate_duration, if: -> { saved_change_to_clock_out_at? && clock_out_at.present? }
  after_create :schedule_auto_completion

  def clock_out!
    if active?
      update(clock_out_at: Time.current, status: :completed)
      true
    else
      false
    end
  end

  def calculate_duration
    if clock_out_at.present? && clock_in_at.present?
      duration_seconds = (clock_out_at - clock_in_at).to_i
      update_column(:duration, duration_seconds)
    end
  end

  def auto_complete!
    return unless active? # Only auto-complete if the record is still active
    return if clock_in_at > AUTO_COMPLETE_THRESHOLD.ago # Only auto-complete if the record is older than the threshold

    self.clock_out_at = calculate_default_clock_out_time
    self.status = :auto_completed
    save!
  end


  private

  def no_active_sleep_record
    if user && user.active_sleep_record.present?
      errors.add(:base, "You already have an active sleep record")
    end
  end

  def clock_out_after_clock_in
    if clock_out_at <= clock_in_at
      errors.add(:clock_out_at, "must be after clock in time")
    end
  end

  def calculate_default_clock_out_time
    # Try to find the average duration of completed sleep records in the past 30 days
    # if there are no completed records in the past 30 days, use the DEFAULT_DURATION
    past_records = user.sleep_records.completed.where("clock_in_at > ?", 30.days.ago)
    default_duration = past_records.empty? ? DEFAULT_DURATION : past_records.average(:duration)

    clock_in_at + default_duration
  end

  def schedule_auto_completion
    AutoCompleteSleepRecordsWorker.perform_in(AUTO_COMPLETE_THRESHOLD, id)
  end
end
