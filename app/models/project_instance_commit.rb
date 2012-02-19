# Attributes:
# * id [integer, primary, not null] - primary key
# * commit_id [integer] - belongs_to Commit
# * created_at [datetime] - creation time
# * data_yaml [text] - serialized data associated with commit
# * preparation_log [text] - commaound output of first time commit preparation (use data maybe?)
# * project_instance_id [integer] - belongs_to ProjectInstance
# * state [string, default=new] - current state, 'new' -> ( 'prepared' | 'preparation_failed' )
# * updated_at [datetime] - last update time
class ProjectInstanceCommit < ActiveRecord::Base

  belongs_to :commit
  belongs_to :project_instance

  validates_presence_of :commit_id
  validates_presence_of :project_instance_id

  validates_uniqueness_of :commit_id, :scope => :project_instance_id

  def prepared?
    self.state == 'prepared'
  end

  def parent
    commit.parent.try(:in_instance, project_instance)
  end

  def data=(value)
    self.data_yaml = value.to_yaml
  end

  def data
    YAML.load(self.data_yaml)
  end

end
