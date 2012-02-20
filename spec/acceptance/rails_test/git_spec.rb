require 'spec_helper'

describe "git VCS in rails_test" do

  it "should recognize commits properly" do
    project = Factory.create(:project, :vcs_type => "Git")
    instance = Factory.create(:project_instance, :project => project)
    FileUtils.cp_r "#{$test_app_skel_dir}//.", instance.working_directory

    # switch to first commit
    puts instance.working_directory
    assert system("cd #{instance.working_directory} && git checkout 836db4770495")

    git = instance.vcs
    git.update

    head_commit = instance.head_commit
    head_commit.should be_kind_of(Commit)
    head_commit.number.should == "836db47704953558b95237b889a49877b502b907"
    head_commit.next.number.should == "07a64e23c55dd134ee23b1c7f7c75819d6a83082"
  end
end
