require 'spec_helper'

describe TestSuite do
  it "should return proper runner class" do
    ts = Factory :test_suite, :suite_type => 'Command'
    ts.runner_class.should be_kind_of Class
    ts.runner_class.should == Moci::TestRunner::Command
  end
end

