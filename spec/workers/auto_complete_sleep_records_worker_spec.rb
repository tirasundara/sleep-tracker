# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AutoCompleteSleepRecordsWorker do
  describe '#perform' do
    context 'when the sleep record exists' do
      let(:sleep_record) { create(:sleep_record, clock_in_at: 1.day.ago, clock_out_at: nil, status: :active) }

      it 'auto-completes the sleep record' do
        AutoCompleteSleepRecordsWorker.new.perform(sleep_record.id)

        expect(sleep_record.reload.status).to eq('auto_completed')
        expect(sleep_record.reload.clock_out_at).to be_present
      end
    end
  end
end
