class CreateProjectInstanceCommits < ActiveRecord::Migration
  def self.up
    create_table :project_instance_commits do |t|
      t.integer :commit_id
      t.integer :project_instance_id
      t.string :state, :default => 'new'
      t.text :preparation_log
      t.text :data_yaml
      t.timestamps
    end
  end

  def self.down
    drop_table :project_instance_commits
  end
end
