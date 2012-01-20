class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string :name
      t.string :notification_type
      t.text :notification_options
      t.timestamps
    end
  end

  def self.down
    drop_table :notifications
  end
end
