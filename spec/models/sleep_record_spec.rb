# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  it { should belong_to(:user) }

  it { should validate_presence_of(:clock_in_at) }
  it { should define_enum_for(:status).with_values(active: 0, completed: 1, auto_completed: 2) }

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

  describe 'callbacks' do
    describe '#schedule_auto_completion' do
      let(:user) { create(:user) }

      it 'schedules auto-completion job after create' do
        sleep_record = create(:sleep_record, user: user)

        expect(AutoCompleteSleepRecordsWorker).to have_enqueued_sidekiq_job.with(sleep_record.id).in(12.hours)
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
          expect(sleep_record.clock_out_at).to be_within(1.second).of(Time.current)
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

  describe '#auto_complete!' do
    let(:user) { create(:user) }
    let(:sleep_record) { create(:sleep_record, user: user, clock_in_at: 1.day.ago, clock_out_at: nil, status: :active) }

    context 'when the sleep record is active' do
      it 'completes the sleep record' do
        sleep_record.auto_complete!

        expect(sleep_record.status).to eq('auto_completed')
        expect(sleep_record.clock_out_at).to be_present
      end
    end

    context 'when the sleep record is not active' do
      before do
        sleep_record.clock_out!
      end

      it 'does not change the status' do
        expect { sleep_record.auto_complete! }.not_to change(sleep_record, :status)
      end
    end

    context 'when the sleep record clock_in_at is more than 12 hours ago' do
      before do
        sleep_record.update(clock_in_at: 13.hours.ago, clock_out_at: nil)
      end

      it 'does complete the sleep record' do
        sleep_record.auto_complete!

        expect(sleep_record.status).to eq('auto_completed')
        expect(sleep_record.clock_out_at).to be_present
      end
    end

    context 'when the sleep record clock_in_at is less than 12 hours ago' do
      before do
        sleep_record.update(clock_in_at: 11.hours.ago, clock_out_at: nil)
      end

      it 'does not complete the sleep record' do
        expect { sleep_record.auto_complete! }.not_to change(sleep_record, :status)
      end
    end
  end
end
