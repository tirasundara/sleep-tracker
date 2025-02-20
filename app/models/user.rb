# frozen_string_literal: true

class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy

  validates :name, presence: true

  def active_sleep_record
    sleep_records.active.order(created_at: :desc).first
  end
end
