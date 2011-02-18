class CreateCommits < ActiveRecord::Migration
  def self.up
    create_table :commits do |t|
      t.string :number
      t.text :description
      t.integer :author_id
      t.timestamps
    end
  end

  def self.down
    drop_table :commits
  end
end
