class CreateSleepRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in_at, null: false
      t.datetime :clock_out_at
      t.integer :duration  # in seconds
      t.integer :status, null: false, default: 0  # 0: active, 1: completed, 2: auto_completed

      t.timestamps
    end

    # indexes
    add_index :sleep_records, :duration
    add_index :sleep_records, :created_at
    add_index :sleep_records, :status
    add_index :sleep_records, [ :user_id, :status ]
    add_index :sleep_records, [ :user_id, :clock_in_at ]
  end
end
