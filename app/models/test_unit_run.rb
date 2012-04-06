# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * result [string] - 'W' - waiting, '.' - OK, 'E' - error, 'F' - failure, 'U' - undefined
# * run_time [float] - time taken to run this test
# * test_suite_run_id [integer] - belongs_to TestSuiteRun
# * test_unit_id [integer] - belongs_to TestUnit
class TestUnitRun < ActiveRecord::Base
  belongs_to :test_unit
  belongs_to :test_suite_run

  scope :with_error, :conditions => {:result => %w{F E}}

  def with_error?
    result == 'F' || result == 'E'
  end

  # Live web notifications TODO: move to observer
  after_save do
    Webs.notify :test_unit_run, self
  end
end
