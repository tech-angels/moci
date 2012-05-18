# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * name [string]
# * project_id [integer] - belongs_to Project
# * suite_options [text] - test suite specific options to be passed to test runner (e.g' which files to
#   include/exclude)
# * suite_type [string] - test suite type, name same as test runner class name (inside Moci::TestRunner)
# * updated_at [datetime] - last update time
require 'moci/test_runner/spec' #FIXME this should not be necessary here

class TestSuite < ActiveRecord::Base

  belongs_to :project

  has_many :test_units
  has_many :test_suite_runs

  validates_presence_of :suite_type #TODO validate value
  validates_presence_of :name

  serialize :suite_options, Hash

  include DynamicOptions::Model

  has_dynamic_options :definition => lambda { runner_class ? runner_class.options_definition : {} }

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
    Moci::TestRunner.const_get suite_type unless suite_type.blank?
  end

  def options
    # TODO merge on default suite_type options
    (suite_options || {}).with_indifferent_access
  end

  def options=(new_options)
    self.suite_options = new_options
  end

end
