require 'spec_helper'

describe Moci::ProjectHandler::Rails do
  let :rails_instance do
    project = Factory.create :project, :project_type => 'Rails'
    instance = Factory.create :project_instance, :project => project
  end

  it "should track exit status correctly" do
    rails_instance.project_handler.should be_kind_of(Moci::ProjectHandler::Rails)
    rails_instance.execute("exit 0").should == true
    rails_instance.execute("exit 1").should == false
  end

  it "should have default options" do
    options = rails_instance.project_handler.send(:options)
    options[:db_structure_dump].should == true
  end

  it "should be possible to overwrite default options" do
    rails_instance.project.update_attributes! :project_options => {:rails => {'db_structure_dump' => false}} # testing indifferent access
    options = rails_instance.project_handler.send(:options)
    options[:db_structure_dump].should == false
  end

  it "should include rvm command when rvm option is set" do
    pi = rails_instance
    pr = pi.project.update_attributes! :project_options => {:rails => {:rvm => '1.8.7@foo'}}

    pi.project_handler.execute_wrapper("moo") do |command, output|
      command.should include('rvm use 1.8.7@foo &&')
    end
  end

  it "should not include rvm command when rvm option is not set" do
    rails_instance.project_handler.execute_wrapper("moo") do |command, output|
      command.should_not include('rvm use')
    end
  end
end
