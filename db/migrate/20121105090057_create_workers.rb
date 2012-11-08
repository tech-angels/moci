class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.integer :pid, :unsigned => true, :null => false
      t.integer :worker_type_id, :null => false, :size => 4
      t.string :state
      t.text :task
      t.timestamp :last_seen_at
      t.timestamp :created_at
    end
  end
end
