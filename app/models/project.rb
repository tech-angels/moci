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

end
