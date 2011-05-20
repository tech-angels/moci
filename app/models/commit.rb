class Commit < ActiveRecord::Base
  #TODO? maybe: commiter? multiple parents?
  #
  belongs_to :author
  belongs_to :project

  has_many :test_suite_runs

  def short_description
    desc = description.split("\n").first
    if desc.size > 100
      desc = desc[0..97] + '...'
    end
    desc
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

  def prepare
    puts "preparing commit #{self.id}"
    # FIXME this will fail for merges, some true db copies may be needed
    if parent && !parent.prepared?
      parent.prepare
    end
    project.prepare_env(self)
  end

  def build_state
    # OPTIMIZE like hell
    new_errors = latest_test_suite_runs.compact.map(&:new_errors).map(&:size).sum
    errors = latest_test_suite_runs.compact.map(&:errors).map(&:size).sum
    if latest_test_suite_runs.any? {|x| x.nil?}
      if latest_test_suite_runs.compact.any?(&:running?)
        return 'running'
      else
        return 'pending'
      end
    end
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

  def checkout
    puts "Checking out #{self.id} #{self.number}"
    project.vcs.checkout self
  end

  def prepared?
    !! self.preparation_log
  end
end
