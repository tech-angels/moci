class TestUnitRun < ActiveRecord::Base
  belongs_to :test_unit
  belongs_to :test_suite_run

  scope :with_error, :conditions => {:result => %w{F E}}

  def with_error?
    result == 'F' || result == 'E'
  end
end
