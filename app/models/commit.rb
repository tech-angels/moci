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

  def run_test_suites
    checkout
    prepare
    project.run_test_suites(true)
  end

  def prepare
    # FIXME this will fail for merges, some true db copies may be needed
    if parent && !parent.prepared?
      parent.prepare
    end
    project.prepare_env(self)
  end

  def checkout
    project.vcs.checkout self
  end

  def prepared?
    !! self.preparation_log
  end
end
