require 'spec_helper'

describe Moci::TestRunner::Command do
  let(:cmd) do
    lambda do |command|
      @ts = Factory.create :test_suite, :suite_type => "Command", :suite_options => {'command' => command}
      @tsr = Factory.create :test_suite_run, :test_suite => @ts
      @cmd = Moci::TestRunner::Command.new @tsr
    end
  end

  it "should kill execution after timeout" do
    Moci.stub(:config) { {:default_timeout => 0.1} }
    cmd['sleep 0.2'].run
    @tsr.reload.state.should == 'finished'
    @tsr.run_time.should > 0.1
    @tsr.run_time.should < 1
  end

  it "should properly collect exit status when false" do
    cmd['/bin/false'].run
    @tsr.reload.exitstatus.should == false
  end

  it "should properly collect exit status when true" do
    cmd['/bin/true'].run
    @tsr.reload.exitstatus.should == true
  end

  it "should properly collect command output" do
    cmd["echo 'science'"].run
    @tsr.reload.run_log.should include('science')
  end

end
