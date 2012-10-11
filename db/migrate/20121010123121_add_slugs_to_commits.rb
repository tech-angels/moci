class AddSlugsToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :slug, :string
    add_index  :commits, [:project_id, :slug], unique: true
    Commit.find_each(&:save)
  end
end
