require 'spec_helper'

describe TestSuite do
  context "runner class" do
    it "should return proper runner class" do
      ts = Factory :test_suite, :suite_type => 'Command'
      ts.runner_class.should be_kind_of Class
      ts.runner_class.should == Moci::TestRunner::Command
    end

    it "should handle blank proprerly" do
      ts = Factory :test_suite
      ts.suite_type = ""
      ts.runner_class.should be_nil
    end
  end
end


