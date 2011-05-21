class CreateProjectInstances < ActiveRecord::Migration
  def self.up
    create_table :project_instances do |t|
      t.integer :project_id
      t.string :state, :default => 'new'
      t.string :locked_by
      t.string :working_directory
      t.timestamps
    end

    #TODO: remove it before release, nobody uses it yet,
    # simply don't add working_directory to projects
    Project.all.each do |project|
      instance = ProjectInstance.new
      instance.project = project
      instance.working_directory = project.working_directory
      instance.save!
    end

    remove_column :projects, :working_directory
    add_column :test_suite_runs, :project_instance_id, :integer
  end

  def self.down
    drop_table :project_instances
    add_column :projects, :working_directory, :string
    remove_column :test_suite_runs, :project_instance_id
  end
end
