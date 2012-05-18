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

  it "should fill assertions count if only tests count is provided" do
    tsr = Factory.create(:test_suite_run, :tests_count => 123, :assertions_count => nil)
    tsr.assertions_count.should == 123
  end

  context "build state" do
    let(:tsr) { Factory :test_suite_run, :state => 'finished' }

    it "should be clean if there are no errors" do
      tsr.errors_count = 0
      tsr.clean?.should == true
      tsr.failures_count = 0
      tsr.clean?.should == true
      tsr.failures_count = nil
      tsr.failures_count = 0
    end

    it "should not be clean if errors count != 0" do
      tsr.errors_count = 1
      tsr.clean?.should == false
      tsr.errors_count = 0
      tsr.failures_count = 1
      tsr.clean?.should == false
    end

    it "should have clean state only if exitstatus is true" do
      tsr.errors_count = 0
      tsr.exitstatus = false
      tsr.build_state.should_not == 'clean'
      tsr.exitstatus = true
      tsr.build_state.should == 'clean'
    end

    it "should be ok if there are no new errors" do
      tsr.stub(:errors) { Array.new(2) { Factory :test_unit, :test_suite => tsr.test_suite } }
      tsr.stub(:new_errors) { [] }
      tsr.errors_count = 2
      tsr.build_state.should == 'ok'
    end

    it "should be fail if there are new errors" do
      errs = [ Factory(:test_unit, :test_suite => tsr.test_suite) ]
      tsr.stub(:new_errors) { errs }
      tsr.stub(:errors) { errs }
      tsr.errors_count = 1
      tsr.build_state.should == 'fail'
    end
  end

end
