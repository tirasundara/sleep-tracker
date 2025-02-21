# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:sleep_records).dependent(:destroy) }
  it { should have_many(:active_followings).dependent(:destroy) }
  it { should have_many(:following) }
  it { should have_many(:passive_followings).dependent(:destroy) }
  it { should have_many(:followers) }

  it { should validate_presence_of(:name) }

  describe '#active_sleep_record' do
    let(:user) { create(:user) }

    it 'returns the active sleep record' do
      completed_record = create(:sleep_record, :completed, user: user)
      active_record = create(:sleep_record, user: user)

      expect(user.active_sleep_record).to eq(active_record)
    end

    it 'returns nil when no active sleep record' do
      create(:sleep_record, :completed, user: user)

      expect(user.active_sleep_record).to be_nil
    end
  end

  describe '#follow' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'follows another user' do
      user.follow(other_user)
      expect(user.following?(other_user)).to be true
    end

    it 'does not follow self' do
      user.follow(user)
      expect(user.following?(user)).to be false
    end
  end

  describe '#unfollow' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    before { user.follow(other_user) }

    it 'unfollows a user' do
      user.unfollow(other_user)
      expect(user.following?(other_user)).to be false
    end
  end
end
