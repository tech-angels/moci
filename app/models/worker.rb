# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * last_seen_at [datetime] - columne periodically updated by worker process
# * pid [integer, not null] - worker process pid
# * state [string] - current worker state [idle, working, waiting - for lock on instance]
# * task [text] - currently executed task in form of JSON
# * worker_type_id [integer, not null] - see Worker::TYPE
class Worker < ActiveRecord::Base

  # Master worker spawns slave and these are workers that are actually running some tests
  TYPES = {
    0 => :master,
    1 => :slave
  }

  # How often should worker report that it is alive
  PING_FREQUENCY = 30

  # Current task, stored as serialized hash:
  # * name - human readable task to display in UI
  # * task_id - currently processed queue element
  # * project_instance_id - instance used
  serialize :task, Hash

  validates :worker_type_id, inclusion: {in: TYPES.keys}

  scope :alive, lambda { where('last_seen_at >= ?', Time.now - PING_FREQUENCY*2) }
  scope :dead, lambda { where('last_seen_at < ?', Time.now - PING_FREQUENCY*2) }

  scope :slave, where(worker_type_id: TYPES.invert[:slave])
  scope :master, where(worker_type_id: TYPES.invert[:master])

  def self.cleanup
    dead.delete_all
  end

  def alive?
    last_seen_at > Time.now - PING_FREQUENCY*2
  end

  def worker_type
    TYPES[worker_type_id]
  end

  def worker_type=(name)
    self.worker_type_id = TYPES.invert[name.to_sym]
  end

  after_save do
    Webs.notify :worker, self
  end
end
