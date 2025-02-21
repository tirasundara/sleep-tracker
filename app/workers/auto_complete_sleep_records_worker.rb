class AutoCompleteSleepRecordsWorker
  include Sidekiq::Worker

  def perform(sleep_record_id)
    sleep_record = SleepRecord.find_by(id: sleep_record_id)
    return unless sleep_record

    sleep_record.auto_complete!
  end
end
