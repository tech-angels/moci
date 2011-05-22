class Project < ActiveRecord::Base
  validates_presence_of :name

  has_many :commits
  has_many :test_suites
  has_many :project_instances
  alias instances project_instances

  has_and_belongs_to_many :notifications

  def newest_commit
    commits.order('committed_at DESC').first
  end

  def acquire_instance(handle, wait = false)
    #TODO: wait == true
    instances.all.each do |instance|
      return instance if instance.try_to_acquire(handle)
    end
    return false
  end

end
