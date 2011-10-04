class AddCommitsSkipped < ActiveRecord::Migration
  def self.up
    add_column :commits, :skipped, :boolean, :default => false
  end

  def self.down
    remove_colmun :commits, :skipped
  end
end
