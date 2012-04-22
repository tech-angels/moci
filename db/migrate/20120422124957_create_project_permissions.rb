class CreateProjectPermissions < ActiveRecord::Migration
  def change
    create_table :project_permissions do |t|
      t.references :user
      t.references :project
      t.string :name
      t.timestamp :created_at
    end

    add_index :project_permissions, :user_id
    add_index :project_permissions, :project_id
  end
end
