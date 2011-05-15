class Commit < ActiveRecord::Base
  #TODO? maybe: commiter? multiple parents?
  #
  belongs_to :author
  belongs_to :project

  has_many :test_suite_runs

  def parent
    #FIXME TODO XXX
    project.commits.order('committed_at DESC').where('committed_at < ?',self.committed_at).first
  end

  def next
    #FIXME TODO XXX
    project.commits.order('committed_at ASC').where('committed_at > ?',self.committed_at).first
  end
end
