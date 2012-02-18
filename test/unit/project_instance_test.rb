require 'test_helper'

class ProjectInstanceTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  test "locking" do
    project = Factory.create :project
    instance = Factory.create :project_instance, :project => project
    assert instance.try_to_acquire("foo")
    assert !instance.try_to_acquire("baz")
    instance.free!
    assert_nil instance.locked_by
    assert_nil instance.reload.locked_by
    assert instance.try_to_acquire("baz")
    assert_equal instance.locked_by, "baz"
    instance.free!
    assert_nil instance.locked_by
  end

end

