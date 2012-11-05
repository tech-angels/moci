require 'spec_helper'

module Moci
  module TestRunner
    class Runtime;      def self.run(ts); raise ::RuntimeError; end; end
    class Interrupt;    def self.run(ts); raise ::Interrupt;    end; end
    class Blank;        def self.run(ts); true;               end; end
  end
end

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

    it "should return options" do
      ts = Factory :test_suite, :suite_options => {"foo" => "bar"}
      ts.options[:foo].should == 'bar'
    end

    it "should assign options" do
      ts = Factory :test_suite
      ts.options = {"woo" => "hoo"}
      ts.save
      ts.reload.options["woo"].should == "hoo"
    end

    context "run" do
      before do
        @ts = create :test_suite
        @pi = create :project_instance
        @pi.stub(:head_commit).and_return(create :commit)
      end

      it "should create test suite run" do
        @ts.suite_type = 'Blank'
        @ts.run(@pi)
        @ts.test_suite_runs.count.should == 1
      end

      it "should remove test suite if there was interrupt" do
        lambda do
          @ts.suite_type = 'Interrupt'
          @ts.run(@pi)
        end.should raise_error Interrupt
        @ts.test_suite_runs.count.should == 0
      end
    end
  end
end


