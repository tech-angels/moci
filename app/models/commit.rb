class Commit < ActiveRecord::Base
  #TODO? maybe: commiter? multiple parents?
  #
  belongs_to :author
  belongs_to :project

  has_many :test_suite_runs
  has_many :project_instance_commits

  def short_description
    desc = description.split("\n").first
    if desc.size > 100
      desc = desc[0..97] + '...'
    end
    desc
  end

  def short_number
    number[0..8]
  end

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

  def build_state
    # OPTIMIZE like hell
    new_errors = latest_test_suite_runs.compact.map(&:new_errors).map(&:size).sum
    errors = latest_test_suite_runs.compact.map(&:errors).map(&:size).sum
    return 'running'  if first_test_suite_runs.compact.any?(&:running?)
    return 'preparation_failed' if project_instance_commits.any? {|c| c.state == 'preparation_failed'} # FIXME
    return 'pending'  if latest_test_suite_runs.any? {|x| x.nil?}
    return 'fail' if new_errors > 0
    return 'ok' if new_errors == 0 && errors > 0
    return 'clean' if errors == 0
  end

  def notify_test_suite_done(tsr)
    if build_state != 'pending'
      project.notifications.each do |notif|
        notif.commit_built(self)
      end
    end
  end

  def latest_test_suite_runs
    # OPTIMIZE
    @latest_test_suite_runs ||= project.test_suites.map do |ts|
      test_suite_runs.where(:test_suite_id => ts.id).order('created_at DESC').first
    end
  end

  def first_test_suite_runs
    # OPTIMIZE
    @first_test_suite_runs ||= project.test_suites.map do |ts|
      test_suite_runs.where(:test_suite_id => ts.id).order('created_at ASC').first
    end
  end

  # returns ProjectInstanceCommit for given instance if exists
  # TODO: I really don't like that method name
  def in_instance(project_instance)
    project_instance.commits.find_by_commit_id(self.id)
  end

  def prepared?
    ProjectInstanceCommit.where(:commit_id => self.id).any? &:prepared?
  end

end
