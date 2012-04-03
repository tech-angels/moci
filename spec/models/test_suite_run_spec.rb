require 'spec_helper'

describe TestSuiteRun do
  it "should respond to running?" do
    tsr = Factory :test_suite_run, :state => 'running'
    tsr.running?.should == true
    tsr.state = 'finished'
    tsr.running?.should === false
  end

  it "should return previous run and parent runs correctly" do
    pr = Factory.create :project
    ts = Factory.create :test_suite, :project => pr
    c1, c2 = Array.new(2) { Factory.create(:commit, :project => pr) }
    c1.parents << c2
    tsr = Factory.create :test_suite_run, :test_suite => ts, :commit => c1
    tsr.previous_run.should == nil
    tsr.parent_runs.should be_empty

    tsr2 = Factory.create :test_suite_run, :test_suite => ts, :commit => c2
    tsr = TestSuiteRun.find(tsr.id)
    tsr.reload.previous_run.should == tsr2
    tsr.parent_runs.should == [tsr2]
  end


end
