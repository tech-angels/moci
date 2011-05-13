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
end
