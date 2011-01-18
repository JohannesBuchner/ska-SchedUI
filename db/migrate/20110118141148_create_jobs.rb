class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.float :lstmin
      t.float :lstmax
      t.integer :hours
      t.references :Proposal

      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
