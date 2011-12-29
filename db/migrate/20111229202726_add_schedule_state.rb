class AddScheduleState < ActiveRecord::Migration
  def self.up
    add_column :schedules, :state, :string
  end

  def self.down
    remove_column :schedules, :state
  end
end
