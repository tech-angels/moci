# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * name [string]
# * project_type [string, default=Base] - same as class name that will be used as project handler
#   (Moci::ProjectHandler::..)
# * updated_at [datetime] - last update time
# * vcs_branch_name [string]
class Project < ActiveRecord::Base
  validates_presence_of :name

  has_many :commits, :dependent => :destroy
  has_many :test_suites, :dependent => :destroy
  has_many :project_instances, :dependent => :destroy

  has_many :test_suite_runs, :through => :project_instances, :dependent => :destroy

  alias instances project_instances

  has_and_belongs_to_many :notifications

  serialize :project_options, Hash

  def newest_commit
    commits.order('committed_at DESC').first
  end

  def acquire_instance(handle, wait = false)
    #TODO: wait == true
    free_instance = nil
    instances.all.each do |instance|
      if instance.try_to_acquire(handle)
        free_instance = instance
        break
      end
    end

    if block_given? && free_instance
      begin
        yield(free_instance)
      ensure
        free_instance.reload.free!
      end
    else
      return free_instance
    end
  end

  def options
    #TODO merge over defaults
    project_options
  end

  #FIXME reorganize this
  def vcs_branch_name
    instances.first.vcs.branch_name
  end

end
