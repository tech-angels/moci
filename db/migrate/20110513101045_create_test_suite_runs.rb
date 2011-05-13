class CreateTestSuiteRuns < ActiveRecord::Migration
  def self.up
    create_table :test_suite_runs do |t|
      t.integer :test_suite_id
      t.integer :commit_id
      t.integer :test_count
      t.integer :assertions_count
      t.integer :failures_count
      t.integer :errors_count
      t.float :run_time
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :test_suite_runs
  end
end
