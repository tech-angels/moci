# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * name [string]
# * project_options [text]
# * project_type [string, default=Base] - same as class name that will be used as project handler
#   (Moci::ProjectHandler::..)
# * public [boolean] - TODO: document me
# * updated_at [datetime] - last update time
# * vcs_type [string, default=Base] - VCS type e.g. Git, Mercurial (see Moci::VCS::Base)
class Project < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :commits, :dependent => :destroy
  has_many :test_suites, :dependent => :destroy
  has_many :project_instances, :dependent => :destroy
  has_many :test_suite_runs, :through => :project_instances, :dependent => :destroy
  has_many :project_permissions
  has_many :users, :through => :project_permission

  alias instances project_instances

  has_and_belongs_to_many :notifications

  serialize :project_options, Hash

  validates :name, :presence => true
  validates :project_type, :presence => true, :inclusion => { :in => Moci::ProjectHandler.types}
  validates :vcs_type, :presence => true, :inclusion => { :in => Moci::VCS.types}

  scope :public, where(:public => true)

  include DynamicOptions::Model

  has_dynamic_options :definition => lambda {  (project_handler_class.try(:options_definition) || {}).merge(vcs_class.try(:options_definition) || {}) }

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
    (project_options || {}).with_indifferent_access
  end

  def options=(new_options)
    self.project_options = new_options
  end

  def project_handler_class
    @project_handler_class = ::Moci::ProjectHandler.const_get(project_type.camelize) unless project_type.blank?
  end

  def vcs_class
    @vcs_class = ::Moci::VCS.const_get(vcs_type.camelize) unless vcs_type.blank?
  end

  #FIXME reorganize this
  def vcs_branch_name
    instances.first.try(:vcs).try(:branch_name)
  end

end
