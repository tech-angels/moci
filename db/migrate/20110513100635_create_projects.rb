class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.string :working_directory
      t.text :project_options
      t.string :vcs_type, :default => 'Base'
      t.string :project_type, :default => 'Base'
      t.timestamps
    end

    add_column :commits, :project_id, :integer
  end

  def self.down
    drop_table :projects
    remove_column :commits, :project_id
  end
end
