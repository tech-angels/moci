require 'spec_helper'

describe ProjectInstance do

  it "should properly lock" do
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

  it "should collect output from execution" do
    instance = Factory.create :project_instance
    output = ''
    assert instance.execute "echo 'this is test'", output
    lines = output.split("\n")
    assert lines[0].starts_with? '$' # first line is command being executed
    assert_equal lines[1], '' # second separating line
    assert_equal lines[2], 'this is test'
  end

  it "should track execution status" do
    instance = Factory.create :project_instance
    assert instance.execute("exit 0")
    assert !instance.execute("exit 1")
  end

  it "should raise on execute!" do
    instance = Factory.create :project_instance
    instance.execute!("exit 0")
    assert_raise RuntimeError do
      instance.execute!("exit 1")
    end
  end
end
