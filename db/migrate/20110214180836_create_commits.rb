class CreateCommits < ActiveRecord::Migration
  def self.up
    create_table :commits do |t|
      t.string :number
      t.text :description
      t.integer :author_id
      t.integer :parent_id
      t.timestamp :committed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :commits
  end
end
