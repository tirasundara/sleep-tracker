class SleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :clock_in_at, :clock_out_at, :duration, :status, :created_at
end
