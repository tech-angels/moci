require 'spec_helper'
require 'ruby-debug'

describe Moci::TestRunner::Base do
  before :each do
    @tsr = Factory.create(:test_suite_run)
    @base = Moci::TestRunner::Base.new @tsr
  end

  it "should provide working_directory method for ancestors" do
    @base.send(:working_directory).should == @tsr.project_instance.working_directory
  end

  it "should provide options method with test suite options for ancestors" do
    @base.send(:options).should == @tsr.test_suite.options
    @base.send(:options).should be_kind_of Hash
  end

  context "push method" do
    it "should accept single value syntax" do
      @tsr.tests_count.should be_nil
      @base.send(:push, :tests_count, 5)
      @tsr.reload.tests_count.should == 5
    end

    it "should accept hash syntax" do
      @tsr.errors_count.should be_nil
      @tsr.failures_count.should be_nil
      @base.send(:push, {:errors_count => 2, :failures_count => 3})
      @tsr.reload.errors_count.should == 2
      @tsr.failures_count.should == 3
    end

    it "should state properly when finished is passed" do
      @tsr.state.should == 'running'
      @base.send(:push, :finished, true)
      @tsr.reload.state.should == 'finished'
    end

    it "should save other values properly" do
      @base.send(:push, {:assertions_count => 123, :exitstatus => false, :run_time => 321, :output => 'oink'})
      @tsr.reload.assertions_count.should == 123
      @tsr.run_time.should == 321
      @tsr.exitstatus.should == false
      @tsr.run_log.should == 'oink'
    end
  end

  it "should be possible to push new test running and result" do
    @base.send(:push_test, "foo bar", "Baz")
    @tsr.reload.test_unit_runs.size.should == 1
    tur = @tsr.test_unit_runs.first
    tur.test_unit.name.should == "foo bar"
    tur.test_unit.class_name.should == "Baz"
    tur.result.should == "W"
  end

  it "should be possible to push test result with time" do
    @base.send(:push_test, "foo bar", "Baz")
    @base.send(:last_test, 'F')
    tur = @tsr.test_unit_runs.first
    tur.reload.result.should == 'F'
  end

  it "should be possible to push test result with time" do
    @base.send(:push_test, "foo bar", "Baz")
    @base.send(:last_test, '.', 2.03)
    tur = @tsr.test_unit_runs.first
    tur.reload.result.should == '.'
    tur.run_time.should == 2.03
  end

  it "should call execute on project instance" do
    tsr = double('test suite run')
    pi = double('project instance')
    pi.should_receive(:execute).with('foo','bar')
    tsr.stub(:project_instance) { pi }
    @base = Moci::TestRunner::Base.new(tsr)
    @base.send :execute, 'foo', 'bar'
  end

  it "should kill execution after timeout" do
    tsr = Factory.create(:test_suite_run)
    pi = double('project instance')
    tsr.stub(:project_instance) { pi }
    pi.stub(:execute) { sleep 5 }
    Moci.stub(:config) { {:default_timeout => 1} }
    @base = Moci::TestRunner::Base.new(tsr)
    @base.send :execute, 'foo'
    tsr.reload.state.should == 'finished'
    tsr.run_log.should include("Timeout::Error")
    tsr.run_time.should == 1
    tsr.exitstatus.should == false
    tsr.build_state.should == 'fail'
  end

  it "should properly track status of executed commands" do
    @base.send(:execute, "exit 0").should == true
    @base.send(:execute, "exit 1").should == false
  end

end
