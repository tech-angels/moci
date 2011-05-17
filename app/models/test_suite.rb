class TestSuite < ActiveRecord::Base
  belongs_to :project

  has_many :test_units

  validates_presence_of :suite_type #TODO validate value
  validates_presence_of :name

  def run
    tr = TestSuiteRun.create!(
      :state => 'running',
      :commit => project.head_commit,
      :test_suite => self)
    runner_class.run(tr)
  end

  def runner_class
    Moci::TestRunner.const_get suite_type
  end
end
