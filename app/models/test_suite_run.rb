class TestSuiteRun < ActiveRecord::Base
  belongs_to :test_suite
  belongs_to :commit

  has_many :test_unit_runs

  def running?
    state == 'running'
  end

  def clean?
    errors_count == 0 && failures_count == 0
  end

  def previous_run
    commit.parent &&
      commit.parent.test_suite_runs.where(:test_suite_id => test_suite.id).
      order('created_at DESC').first
  end

  def new_errors
    test_unit_runs.includes(:test_unit).with_error.map (&:test_unit) -
    previous_run.test_unit_runs.includes(:test_unit).with_error.map (&:test_unit)
  end

  def gone_errors
    previous_run.test_unit_runs.includes(:test_unit).with_error.map (&:test_unit) -
    test_unit_runs.includes(:test_unit).with_error.map (&:test_unit)
  end

  def errors
    test_unit_runs.includes(:test_unit).with_error.map (&:test_unit)
  end

end
