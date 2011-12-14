class AddTimedAtToSchedule < ActiveRecord::Migration
  def self.up
    add_column :schedules, :timed_at, :datetime
  end

  def self.down
    remove_column :schedules, :timed_at
  end
end
