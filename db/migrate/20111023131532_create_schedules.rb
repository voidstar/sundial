class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.string :name
      t.string :group
      t.string :callback_url
      t.string :cron
      t.string :time_zone
      t.integer :quartz_id
      t.text :callback_params
      t.text :timing

      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
