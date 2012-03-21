class CreateCommitsParents < ActiveRecord::Migration
  def self.up
    create_table :commits_parents, :id => false do |t|
      t.integer :commit_id
      t.integer :parent_id
    end
  end

  def self.down
    drop_table :commits_parents
  end
end
