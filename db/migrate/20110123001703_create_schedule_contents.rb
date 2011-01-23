class CreateScheduleContents < ActiveRecord::Migration
  def self.up
    create_table :schedule_contents do |t|
      t.integer :timeslot
      t.references :Schedule
      t.references :Job

      t.timestamps
    end
  end

  def self.down
    drop_table :schedule_contents
  end
end
