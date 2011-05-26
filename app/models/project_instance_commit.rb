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
