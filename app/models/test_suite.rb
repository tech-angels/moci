class TestSuite < ActiveRecord::Base
  belongs_to :project

  has_many :test_units

  #TODO: suite types

  def run
    #TODO: decide which runner based on type
    tr = TestSuiteRun.create!(
      :state => 'running',
      :commit => project.current_commit,
      :test_suite => self)
    Moci::TestRunner::Unit.run(tr)
  end
end
