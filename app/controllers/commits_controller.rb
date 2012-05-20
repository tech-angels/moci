class CommitsController < ApplicationController

  def index
    must_be_in_project
    @commits = @project.commits.order('committed_at DESC').page(params[:page]).per(10)
  end

  def show
    @commit = Commit.find params[:id]
    @project = @commit.project
    must_be_in_project
  end

  def rerun_all_children
    @commit = Commit.find params[:id]
    @project = @commit.project
    permission_denied! unless can? :manage, @project
    ([@commit] + @commit.all_children).each &:rerun_test_suites
    redirect_to :back, :notice => "Test suites have been scheduled to rerun" 
  end
end
