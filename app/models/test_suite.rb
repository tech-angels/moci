require 'moci/test_runner/rspec' #FIXME this should not be necessary here

class TestSuite < ActiveRecord::Base

  belongs_to :project

  has_many :test_units

  validates_presence_of :suite_type #TODO validate value
  validates_presence_of :name

  serialize :suite_options, Hash

  # Run TestSuite within given ProjectInstance
  def run(project_instance)
    puts " running test suite #{self.name}"
    tr = TestSuiteRun.create!(
      :state => 'running',
      :commit => project_instance.head_commit,
      :project_instance => project_instance,
      :test_suite => self)
    runner_class.run(tr)
    tr.after_run #TODO: events, successful finish
  end

  # Returns given test suite runner implementation class
  def runner_class
    Moci::TestRunner.const_get suite_type
  end

  def options
    # TODO merge on default suite_type options
    suite_options
  end

end
