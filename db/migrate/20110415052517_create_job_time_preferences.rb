class CreateJobTimePreferences < ActiveRecord::Migration
  def self.up
    create_table :job_time_preferences do |t|
      t.integer :starttime
      t.integer :endtime
      t.integer :preferredJob

      t.timestamps
    end
  end

  def self.down
    drop_table :job_time_preferences
  end
end
