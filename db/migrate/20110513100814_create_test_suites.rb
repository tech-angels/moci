class CreateTestSuites < ActiveRecord::Migration
  def self.up
    create_table :test_suites do |t|
      t.string :name
      t.string :suite_type
      t.text :suite_options
      t.integer :project_id
      t.timestamps
    end
  end

  def self.down
    drop_table :test_suites
  end
end
