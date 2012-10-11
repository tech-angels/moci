class AddSlugsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :slug, :string
    add_index  :projects, :slug, unique: true
    Project.find_each(&:save)
  end
end
