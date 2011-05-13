class TestUnitRun < ActiveRecord::Base
  belongs_to :test_unit
  belongs_to :test_suite_run
end
