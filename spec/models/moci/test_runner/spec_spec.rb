require 'spec_helper'
require 'fileutils'

describe Moci::TestRunner::Spec do

  context "using example spec" do
    before :all do
      @ts = Factory.create :test_suite, :suite_type => 'Spec', :suite_options => {'specs' => 'spec/foo_spec.rb'}
      @tsr = Factory.create :test_suite_run
      spec_dir = File.join(@tsr.project_instance.working_directory, 'spec')
      FileUtils.mkdir_p(File.join(@tsr.project_instance.working_directory, 'spec'))
      FileUtils.cp(File.join(Rails.root,'spec','fixtures','example_spec.txt'), File.join(spec_dir,'foo_spec.rb'))
      @spec = Moci::TestRunner::Spec.new @tsr
      @spec.run
      @tsr.reload
    end

    it "should find 4 tests" do
      @tsr.tests_count.should == 4
    end

    it "should count 3 failures" do
      @tsr.errors_count.should == 3
    end

    it "should properly recognize test cases names" do
      @tsr.test_unit_runs.size.should == 4
      @tsr.test_unit_runs.map(&:test_unit).each do |tu|
        tu.class_name.should == "Foo"
      end

      names = ["Boo should assert truth","should raise sometimes","should fail sometimes","should baz"]
      @tsr.test_unit_runs.map(&:test_unit).map(&:name).to_set.should == names.to_set
    end

    it "should properly recognize ok result" do
      @tsr.test_unit_runs.find{|t| t.test_unit.name == "should baz"}.result.should == '.'
    end

    it "should properly recognize fail result" do
      @tsr.test_unit_runs.find{|t| t.test_unit.name == "should fail sometimes"}.result.should == 'F'
    end

    it "should properly recognize another result" do
      @tsr.test_unit_runs.find{|t| t.test_unit.name == "should raise sometimes"}.result.should == 'F'
    end

    it "should properly gather run times" do
      # test case has sleep 0.2 inserted
      # it turns out that some pipe dolay possibly? can make it a bit less than 2
      # that's why it's only checked if greater than 1.5, check if we can IMPROVE
      # Ideally we want these sleeps to be more like 0.2s than 2s
      @tsr.test_unit_runs.find{|t| t.test_unit.name == "should fail sometimes"}.run_time.should > 1.5
    end

    it "should save proper exitstatus" do
      @tsr.exitstatus.should == false
    end
  end

  context "with another example spec" do
    before :all do
      @ts = Factory.create :test_suite, :suite_type => 'Spec', :suite_options => {'specs' => 'spec/foo_spec.rb'}
      @tsr = Factory.create :test_suite_run
      spec_dir = File.join(@tsr.project_instance.working_directory, 'spec')
      FileUtils.mkdir_p(File.join(@tsr.project_instance.working_directory, 'spec'))
      FileUtils.cp(File.join(Rails.root,'spec','fixtures','example_spec2.txt'), File.join(spec_dir,'foo_spec.rb'))
      @spec = Moci::TestRunner::Spec.new @tsr
      @spec.run
      @tsr.reload
    end

    it "should find 2 tests" do
      @tsr.tests_count.should == 2
    end

    it "should save proper exit status" do
      @tsr.exitstatus.should == true
    end

    it "sholud gather stderr output" do
      @tsr.run_log.should include("This is something on STDERR")
    end

  end

end
