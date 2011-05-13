class CreateTestUnits < ActiveRecord::Migration
  def self.up
    create_table :test_units do |t|
      t.integer :test_suite_id
      t.string :class_name
      t.text :name
      t.timestamps
    end
  end

  def self.down
    drop_table :test_units
  end
end
