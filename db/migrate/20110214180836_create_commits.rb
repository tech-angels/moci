class CreateCommits < ActiveRecord::Migration
  def self.up
    create_table :commits do |t|
      t.string :number
      t.text :description
      t.integer :author_id
      t.timestamp :committed_at

      # TODO: think about it, that's probably not the best place to keep it
      t.text :preparation_log

      # FIXME And that's definitely not place to keep it, it should be associated
      # with rails project type, it won't apply to other project types
      t.text :dev_structure

      t.timestamps
    end
  end

  def self.down
    drop_table :commits
  end
end
