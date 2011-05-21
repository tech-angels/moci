class TestSuiteRun < ActiveRecord::Base
  belongs_to :commit
  belongs_to :project_instance
  belongs_to :test_suite

  has_many :test_unit_runs

  scope :finished, :conditions => {:state => 'finished'}

  def running?
    state == 'running'
  end

  def clean?
    errors_count == 0 && failures_count == 0
  end

  def build_state
    return 'clean' if clean?
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
    @new_errrors ||= test_unit_runs.includes(:test_unit).with_error.map(&:test_unit) - previous_run.test_unit_runs.includes(:test_unit).with_error.map(&:test_unit)
  end

  def gone_errors
    return [] unless previous_run
    @gone_errors ||= previous_run.test_unit_runs.includes(:test_unit).with_error.map(&:test_unit) - test_unit_runs.includes(:test_unit).with_error.map(&:test_unit)
  end

  def random_errors
    # OPTIMIZE
    tsrs = commit.test_suite_runs.finished.where(:test_suite_id => test_suite.id).all
    count_all = tsrs.count
    counts = TestUnitRun.where(:test_suite_run_id => tsrs.map(&:id)).with_error.group(:test_unit_id).select('test_unit_id, count(*) as count_all')
    counts = counts.select {|x| x.count_all.to_i != count_all.to_i}
    counts.map {|x| [TestUnit.find(x.test_unit_id), x.count_all.to_f/count_all.to_f]}
  end

  def errors
    @errors ||= test_unit_runs.includes(:test_unit).with_error.map(&:test_unit)
  end

  def after_run
    self.commit.notify_test_suite_done(self) # TODO events
  end

end
