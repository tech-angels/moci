require 'spec_helper'

describe ProjectsController do
  include Devise::TestHelpers

  describe "vewing public project" do
    let(:public_project) { Factory :project, :public => true }

    it "should be finding the project" do
      get :show, :project_name => public_project.name
      assigns(:project).should == public_project
      response.should be_success
    end
  end

  describe "vewing non public project without permission" do
    let(:project) { Factory :project }

    it "should be redirecting" do
      get :show, :project_name => project.name
      response.should be_redirect
    end
  end

  describe "viewiwng non public project as admin" do
    let(:project) { Factory :project }
    let(:admin) { Factory :admin }

    it "should be displaying project" do
      sign_in admin
      get :show, :project_name => project.name
      assigns(:project).should == project
      response.should be_success
    end
  end

  describe "viewing non public project as user without permission" do
    let(:project) { Factory :project }
    let(:user) { Factory :user }

    it "should be redirecting" do
      sign_in user
      get :show, :project_name => project.name
      response.should be_redirect
    end
  end

  describe "viewing non public project as user with permission" do
    let(:project) { Factory :project }
    let(:user) { Factory :user }
    before { user.projects_can_view << project }

    it "should be displaying project" do
      sign_in user
      get :show, :project_name => project.name
      assigns(:project).should == project
      response.should be_success
    end
  end
end
