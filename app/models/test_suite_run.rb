class TestSuiteRun < ActiveRecord::Base
  belongs_to :test_suite
  belongs_to :commit
end
