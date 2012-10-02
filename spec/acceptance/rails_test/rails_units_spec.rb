
require 'spec_helper'

describe "rails units in rails_test" do
    before :all do
      @project = Factory.create(:project, :vcs_type => "Git", :project_type => 'Rails', :project_options => {:rails => {:rvm => "1.9.3"}})
      @instance = Factory.create(:project_instance, :project => @project)
      FileUtils.cp_r "#{$test_app_skel_dir}//.", @instance.working_directory

      # switch to first commit
      puts @instance.working_directory
      assert system("cd #{@instance.working_directory} && git checkout 836db4770495")
    end

    context "after running test suites" do
      before :all do
        @ts = @project.test_suites.create! :name => 'units', :suite_type => 'RailsUnits'
        @instance.ping
      end

      it "should recognize test units" do
        tus = @ts.test_units.map {|tu| [tu.class_name, tu.name]}
        tus.should include(['FooTest','test_the_truth'])
        tus.should include(['FooTest','test_something_else'])
        tus.should include(['FooTest','test_one_much_slower'])
        tus.should include(['FooTest','test_foo_test'])
      end

      it "should mark _keep it failing_ commit as OK" do
        commit = @project.commits.find_by_number '2937f04135130fceed58bdd763f7f120fbf46469'
        commit.build_state.should == 'ok'
      end

      it "should mark _introduce one unit failing_ commit as FAIL" do
        commit = @project.commits.find_by_number 'b2f3ce44b39dabf2d9127d3a91446f8804f75575'
        commit.build_state.should == 'fail'
      end

      it "should marke _fix all test failing_ commit as CLEAN" do
        commit = @project.commits.find_by_number 'f7cbcb2cc9e9bf5561329f26bd8ada990abce51e'
        commit.build_state.should == 'clean'
      end

      it "should have proper results for _introduce one unit failing_ commit" do
        commit = @project.commits.find_by_number 'b2f3ce44b39dabf2d9127d3a91446f8804f75575'
        tsr = commit.test_suite_runs.where(:test_suite_id => @ts.id).first
        tsr.failures_count.should == 1
        tsr.errors_count.should == 0
        tsr.tests_count.should == 6
        tsr.assertions_count.should == 6

        tu = @ts.test_units.where(:class_name => "FooTest", :name => "test_the_truth").first
        tsr.errors.should include(tu)
        tsr.new_errors.should include(tu)
        tsr.errors.size.should == 1
      end

      it "should have proper results for _keep it failing_ commit" do
        commit = @project.commits.find_by_number '2937f04135130fceed58bdd763f7f120fbf46469'
        tsr = commit.test_suite_runs.where(:test_suite_id => @ts.id).first

        tu = @ts.test_units.where(:class_name => "FooTest", :name => "test_the_truth").first
        tsr.errors.should include(tu)
        tsr.new_errors.should be_empty
      end
    end
end
