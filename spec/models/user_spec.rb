# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:sleep_records).dependent(:destroy) }

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
end
