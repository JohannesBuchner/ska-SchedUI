class CreateProposalJobs < ActiveRecord::Migration
  def self.up
    create_table :proposal_jobs do |t|
      t.references :job
      t.references :proposal
      t.timestamps
    end
  end

  def self.down
    drop_table :proposal_jobs
  end
end
