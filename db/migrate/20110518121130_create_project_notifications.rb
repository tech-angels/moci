class CreateProjectNotifications < ActiveRecord::Migration
  def self.up
    # TODO: possibly we will want has_many :through on the long run
    # instead, also not sure if that would be relation with project
    # or maybe just a single branch?
    create_table :notifications_projects, :id => false do |t|
      t.integer :project_id
      t.integer :notification_id
    end
  end

  def self.down
    drop_table :notifications_projects
  end
end
