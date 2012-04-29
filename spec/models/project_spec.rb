require 'spec_helper'

describe Project do
  subject { Factory :project }

  it { should validate_presence_of :name }
  it { should validate_presence_of :project_type }
  it { should validate_presence_of :vcs_type }

  context "project type"  do
    it { should allow_value("Rails").for :project_type }
    it { should_not allow_value("Foobar").for :project_type }
  end

  context "vcs type"  do
    it { should allow_value("Git").for :vcs_type }
    it { should_not allow_value("Moo").for :vcs_type }
  end

  context "project handler class" do
    it "should not raise when project_type is nil" do
      subject.project_type = nil
      subject.project_handler_class.should be_nil
    end

    it "should not raise when project_type is blank" do
      subject.project_type = ""
      subject.project_handler_class.should be_nil
    end

    it "should return proper class" do
      subject.project_type = 'Rails'
      subject.project_handler_class.should == ::Moci::ProjectHandler::Rails
    end
  end

  context "vcs class" do
    it "should not raise when vcs_type is nil" do
      subject.vcs_type = nil
      subject.vcs_class.should be_nil
    end

    it "should not raise when vcs_type is blank" do
      subject.vcs_type = ""l
      subject.vcs_class.should be_nil
    end

    it "should return proper class" do
      subject.vcs_type = "Git"
      subject.vcs_class.should == ::Moci::VCS::Git
    end
  end
end
