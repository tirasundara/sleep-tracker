# frozen_string_literal: true

class SleepRecord < ApplicationRecord
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
end
