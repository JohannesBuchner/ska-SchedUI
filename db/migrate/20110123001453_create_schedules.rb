class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.boolean :enabled
      t.boolean :favorite
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
