require 'spec_helper'

describe "git VCS in rails_test" do

  context "within project instance" do

    before :all do
      @project = Factory.create(:project, :vcs_type => "Git")
      @instance = Factory.create(:project_instance, :project => @project)
      FileUtils.cp_r "#{$test_app_skel_dir}//.", @instance.working_directory

      # switch to first commit
      puts @instance.working_directory
      assert system("cd #{@instance.working_directory} && git checkout 836db4770495")

      @git = @instance.vcs
      @git.update
    end

    it "should recognize commits properly" do
      head_commit = @instance.head_commit
      head_commit.should be_kind_of(Commit)
      head_commit.number.should == "836db47704953558b95237b889a49877b502b907"
      head_commit.next.number.should == "07a64e23c55dd134ee23b1c7f7c75819d6a83082"
    end

    it "should create proper commit objects" do
      third_commit = @project.commits.find_by_number('812adb94fa361b303cf3d362ca9a0cab1225cf2d')
      third_commit.should_not be_nil
      first_commit = @project.commits.find_by_number('836db47704953558b95237b889a49877b502b907')
      first_commit.should_not be_nil
      commit = @project.commits.find_by_number('07a64e23c55dd134ee23b1c7f7c75819d6a83082')
      commit.should_not be_nil

      author = commit.author
      author.should_not be_nil
      author.name.should == "comboy"
      author.email.should == "kacper.ciesla@gmail.com"

      commit.description.should == "added test"
      commit.committed_at.to_date.should == Date.new(2011,5,13)
      commit.parent.should == first_commit
    end

    it "should checkout properly" do
      commit =  @project.commits.find_by_number('812adb94fa361b303cf3d362ca9a0cab1225cf2d')
      @instance.checkout commit
      `cd #{@instance.working_directory} && git rev-parse HEAD`.strip.should == "812adb94fa361b303cf3d362ca9a0cab1225cf2d"
    end

  end
end
