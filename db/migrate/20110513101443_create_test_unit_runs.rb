class CreateTestUnitRuns < ActiveRecord::Migration
  def self.up
    create_table :test_unit_runs do |t|
      t.integer :test_unit_id
      t.integer :test_suite_run_id
      t.float :run_time
      t.string :result, :limit => 1
      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :test_unit_runs
  end
end
