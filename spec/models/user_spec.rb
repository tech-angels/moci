require 'spec_helper'

describe User do
  subject { Factory :user }

  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }

  context "abilities" do
    let(:project) { Factory :project }

    context "admin" do
      let(:admin) { Factory :admin}
      subject { Ability.new(admin) }

      it { should be_able_to :view, project }
      it { should be_able_to :manage, project }
    end

    context "user" do
      let(:user) { Factory :user }
      subject { Ability.new(user) }

      it { should_not be_able_to :view, project }
      it { should_not be_able_to :manage, project }
    end

    context "user with project permission" do
      let(:user) { Factory :user }
      before { user.project_permissions.create!(:project => project, :name => 'view') }
      subject { Ability.new(user) }

      it { should be_able_to :view, project }
      it { should_not be_able_to :manage, project }
    end
  end

  context "project permissions" do
    let(:project) { Factory :project }
    let(:project2) { Factory :project }
    let(:project3) { Factory :project }
    let(:project4) { Factory :project }
    before do
      @project_permissions = []
      @project_permissions << Factory(:project_permission, :project => project, :user => subject, :name => 'view')
      @project_permissions << Factory(:project_permission, :project => project2, :user => subject, :name => 'view')
      @project_permissions << Factory(:project_permission, :project => project3, :user => subject, :name => 'view')
      @project_permissions << Factory(:project_permission, :project => project3, :user => subject, :name => 'manage')
    end

    it "should have many preject permissions" do
      subject.project_permissions.to_set.should == @project_permissions.to_set
    end

    it "should have many projects" do
      subject.projects.to_set.should == [project, project2, project3].to_set
    end

    it "should have many projects that it can view" do
      subject.projects_can_view.to_set.should == [project, project2, project3].to_set
    end

    it "should have many projects that it can manage" do
      subject.projects_can_manage.to_set.should == [project3].to_set
    end
  end
end
