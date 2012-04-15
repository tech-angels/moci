require 'spec_helper'

describe Moci::ProjectHandler::Rails do
  let :rails_instance do
    project = Factory.create :project, :project_type => 'Rails'
    instance = Factory.create :project_instance, :project => project
  end

  it "should track exit status correctly" do
    rails_instance.project_handler.should be_kind_of(Moci::ProjectHandler::Rails)
    rails_instance.execute("/bin/true").should == true
    rails_instance.execute("/bin/false").should == false
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

  context "rvm" do
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

  context "bundler" do
    it "should include bundle exec when executing commands if bundler is enabled" do
      rails_instance.project_handler.execute_wrapper("moo") do |command, output|
        command.should include('bundle exec moo')
      end
    end

    it "should not include bundle exec when executing commands if bundler is not enabled" do
      pi = rails_instance
      pr = pi.project.update_attributes! :project_options => {:rails => {:bundler => false}}
      pi.project_handler.execute_wrapper("moo") do |command, output|
        command.should_not include('bundle exec moo')
      end
    end

    it "should not include bundle exec for bundler commands" do
      rails_instance.project_handler.execute_wrapper("bundle install") do |command, output|
        command.should_not include('bundle exec')
      end

      rails_instance.project_handler.execute_wrapper("bundle check") do |command, output|
        command.should_not include('bundle exec')
      end
    end

    it "should not include bundle exec if it's already in there" do
      rails_instance.project_handler.execute_wrapper("bundle exec moo") do |command, output|
        command.split('bundle exec').size.should == 2
      end
    end

  end
end
