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

  def previous_run
    @previous_run ||= (commit.parent &&
      commit.parent.test_suite_runs.where(:test_suite_id => test_suite.id).
      order('created_at DESC').first)
  end

  def new_errors
    return errors unless previous_run
    @new_errrors ||= test_unit_runs.includes(:test_unit).with_error.map(&:test_unit) - previous_run.test_unit_runs.includes(:test_unit).with_error.map(&:test_unit) - possibly_random
  end

  def gone_errors
    return [] unless previous_run
    @gone_errors ||= previous_run.test_unit_runs.includes(:test_unit).with_error.map(&:test_unit) - test_unit_runs.includes(:test_unit).with_error.map(&:test_unit) - possibly_random
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
    @possibly_random ||= (
      # OPTIMIZE FIXME!! This is AWFULLY suboptimal
      ret = random_errors.map(&:first)
      if @previous_run && go_back > 0
        ret += @previous_run.random_errors.map(&:first)
        ret += @previous_run.possibly_random(go_back - 1)
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

end
