# Attributes:
# * id [integer, primary, not null] - primary key
# * assertions_count [integer] - number of assertions made
# * commit_id [integer] - belongs_to Commit (TODO: shouldn't that be project_instance_commit?)
# * created_at [datetime] - creation time
# * errors_count [integer] - number of errors that occurred during test suite run
# * exitstatus [boolean] - true if execution of the test suite was successful
# * failures_count [integer] - number of failures that occured during test suite run
# * project_instance_id [integer] - belongs_to ProjectInstance
# * run_log [text] - command output of test suite run
# * run_time [float] - total test suite execution time
# * state [string] - currently only 2 states: running -> finished
# * test_suite_id [integer] - belongs_to TestSuite
# * tests_count [integer] - number of tests in the test suite
# * updated_at [datetime] - last update time
class TestSuiteRun < ActiveRecord::Base
  belongs_to :commit
  belongs_to :project_instance
  belongs_to :test_suite

  delegate :project, :to => :test_suite

  has_many :test_unit_runs, :dependent => :destroy

  scope :finished, :conditions => {:state => 'finished'}

  def running?
    state == 'running'
  end

  def clean?
    errors_count == 0 && failures_count == 0
  end

  def build_state
    return 'clean' if clean? && exitstatus
    return 'ok' if new_errors.size == 0 && errors.size != 0
    return 'fail'
  end

  # Returns commit where given TestUnit started failing.
  # Returns false if given TestUnit was not failing in current test suite.
  # IMPROVE we probably can include checking random_errors too, which should make work blaming for
  # randomly failing tests (first occurence of failure) - needs some tests
  def blame(test_unit)
    return false unless errors.include? test_unit
    parent_runs.each do |pr|
      next unless pr
      c = pr.blame(test_unit)
      return c if c
    end
    return commit
  end

  def parent_runs
    @parent_runs ||= (
      commit.parents_without_skipped.map {|c| c.test_suite_runs.where(:test_suite_id => test_suite.id).order('created_at DESC').first }.compact
    )
  end

  # FIXME it's depricated DEPRECATED, it should not be used as it's only based on one parent
  def previous_run
    parent_runs.first
  end

  def new_errors
    return errors if parent_runs.empty?
    @new_errrors ||= test_unit_runs.includes(:test_unit).with_error.map(&:test_unit) - parent_runs.map{|pr| pr.test_unit_runs.includes(:test_unit).with_error.map(&:test_unit)}.flatten.uniq - possibly_random
  end

  def gone_errors
    return [] if parent_runs.empty?
    @gone_errors ||= parent_runs.map{|pr| pr.test_unit_runs.includes(:test_unit).with_error.map(&:test_unit)}.flatten.uniq - test_unit_runs.includes(:test_unit).with_error.map(&:test_unit) - possibly_random
  end

  def random_errors
    # OPTIMIZE
    @random_errors ||= (
      tsrs = commit.test_suite_runs.finished.where(:test_suite_id => test_suite.id).all
      count_all = tsrs.count
      counts = TestUnitRun.where(:test_suite_run_id => tsrs.map(&:id)).with_error.group(:test_unit_id).select('test_unit_id, count(*) as count_all')
      counts = counts.select {|x| x.count_all.to_i != count_all.to_i}
      counts.map {|x| [TestUnit.find(x.test_unit_id), x.count_all.to_f/count_all.to_f]}
    )
  end

  def possibly_random(go_back = 40)
    # FIXME TEMP disabling currently to speed up, below implementation is correct, but before this works fast
    # test unit errors cache must be implemented
    return []
    # FIXME Fix that for multiple parents
    @possibly_random ||= (
      # OPTIMIZE FIXME!! This is AWFULLY suboptimal
      ret = random_errors.map(&:first)
      if previous_run && go_back > 0
        ret += previous_run.random_errors.map(&:first)
        ret += previous_run.possibly_random(go_back - 1)
      end
      ret.uniq
    )
  end

  def errors
    @errors ||= test_unit_runs.includes(:test_unit).with_error.map(&:test_unit)
  end

  #TODO this should be handled by some events
  def after_run
    # Notification

    # We want it to fire only after first run
    before_me_count = TestSuiteRun.where(
      :test_suite_id => test_suite.id,
      :commit_id => commit.id).
      where('created_at < ?', self.created_at).count
    self.commit.notify_test_suite_done(self) if before_me_count == 0
  end


  # Live web notifications TODO: move to observer

  after_save do
    Webs.notify :test_suite_run, self
  end

end
