class CreateBadDates < ActiveRecord::Migration
  def self.up
    create_table :bad_dates do |t|
      t.references :job
      t.datetime :start
      t.datetime :end

      t.timestamps
    end
  end

  def self.down
    drop_table :bad_dates
  end
end
