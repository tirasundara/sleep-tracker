# frozen_string_literal: true

class User < ApplicationRecord
  # Sleep Record relationships
  has_many :sleep_records, dependent: :destroy

  # Follower relationships
  has_many :active_followings, class_name: "Following", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_followings, source: :followed

  # Followed relationships
  has_many :passive_followings, class_name: "Following", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_followings, source: :follower

  validates :name, presence: true

  def active_sleep_record
    sleep_records.active.order(created_at: :desc).first
  end

  def follow(other_user)
    following << other_user unless self == other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end
end
