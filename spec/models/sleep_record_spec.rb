# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  it { should belong_to(:user) }

  it { should validate_presence_of(:clock_in_at) }

  describe 'validations' do
    let(:user) { create(:user) }

    context 'when creating a new sleep record' do
      it 'validates no active sleep record exists' do
        create(:sleep_record, user: user)
        new_record = build(:sleep_record, user: user)

        expect(new_record).to be_invalid
        expect(new_record.errors[:base]).to include("You already have an active sleep record")
      end
    end

    context 'when clocking out' do
      it 'validates clock_out_at is after clock_in_at' do
        record = create(:sleep_record, user: user)
        record.clock_out_at = record.clock_in_at - 1.hour

        expect(record).to be_invalid
        expect(record.errors[:clock_out_at]).to include("must be after clock in time")
      end
    end
  end

  describe '#clock_out!' do
    let(:user) { create(:user) }

    context 'with active sleep record' do
      let!(:sleep_record) { create(:sleep_record, user: user) }

      it 'completes the sleep record' do
        Timecop.freeze(Time.current) do
          expect(sleep_record.clock_out!).to be true
          sleep_record.reload

          expect(sleep_record).to be_completed
          expect(sleep_record.clock_out_at).to eq(Time.current)
        end
      end
    end

    context 'with already completed sleep record' do
      let(:sleep_record) { create(:sleep_record, :completed, user: user) }

      it 'returns false' do
        expect(sleep_record.clock_out!).to be false
      end
    end
  end

  describe '#calculate_duration' do
    let(:user) { create(:user) }

    it 'calculates duration in minutes' do
      record = create(:sleep_record, user: user)
      record.update(clock_out_at: record.clock_in_at + 5.hours)

      expect(record.duration).to eq(18000) # 5 hours in seconds
    end
  end
end
