class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.references :proposal
      t.decimal :startlst
      t.decimal :endlst
      t.decimal :totalhours

      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
