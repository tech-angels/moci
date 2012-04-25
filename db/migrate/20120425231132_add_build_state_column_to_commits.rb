class AddBuildStateColumnToCommits < ActiveRecord::Migration
  def self.up
    add_column :commits, :build_state, :string, :default => 'pending'
    total = Commit.count
    i = 0
    Commit.includes(:project).find_each do |commit|
      commit.update_build_state!
      say "[#{i+=1}/#{total}] updated stete for #{commit.project} #{commit.short_number}: #{commit.build_state}"
    end
  end

  def self.down
    remove_column :commits, :build_state
  end
end
