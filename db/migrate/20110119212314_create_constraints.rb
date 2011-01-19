class CreateConstraints < ActiveRecord::Migration
  def self.up
    create_table :constraints do |t|
      t.references :job

      t.timestamps
    end
  end

  def self.down
    drop_table :constraints
  end
end
