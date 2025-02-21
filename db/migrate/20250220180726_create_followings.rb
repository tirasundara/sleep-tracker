class CreateFollowings < ActiveRecord::Migration[7.2]
  def change
    create_table :followings do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users } # Sets up a foreign key reference to the users table for the follower relationship
      t.references :followed, null: false, foreign_key: { to_table: :users } # Sets up a foreign key reference to the users table for the followed relationship

      t.timestamps
    end

    # Adds a unique index to prevent duplicate follower-followed relationships at the database level
    add_index :followings, [:follower_id, :followed_id], unique: true
  end
end
