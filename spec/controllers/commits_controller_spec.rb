require 'spec_helper'

describe CommitsController do
  include Devise::TestHelpers

  context "show" do
    context "public project" do
    let(:commit) { Factory :commit, :project => Factory(:public_project) }
      it "should display commit" do
        get :show, :project_id => commit.project, :id => commit.id
        response.should be_success
        assigns(:project).should == commit.project
      end
    end

    context "non-public project" do
    let(:commit) { Factory :commit }
      it "should not display commit" do
        get :show, :project_id => commit.project, :id => commit.id
        response.should be_redirect
        flash[:alert].should == "Project not found"
      end

      context "after signing in" do
        before do
          @user = Factory :user
          sign_in @user
        end

        it "should still not display commit" do
          get :show, :project_id => commit.project, :id => commit.id
          response.should be_redirect
          flash[:alert].should == "Project not found"
        end

        context "with permission to view the project" do
          before do
            @user.projects_can_view << commit.project
          end

          it "should display commit" do
            get :show, :project_id => commit.project_id, :id => commit.id
            response.should be_success
            assigns(:project).should == commit.project
          end

        end

      end
    end
  end
end
