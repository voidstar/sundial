class AddScheduleThreshold < ActiveRecord::Migration
  def self.up
    add_column :schedules, :threshold, :integer
  end

  def self.down
    remove_column :schedules, :threshold
  end
end
