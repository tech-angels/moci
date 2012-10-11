class CommitsController < ApplicationController

  before_filter :must_be_in_project

  def index
    @commits = @project.commits.order('committed_at DESC').page(params[:page]).per(10)
  end

  def show
    @commit = @project.commits.find params[:id]
  end

  def rerun_all_children
    @commit = @project.find params[:id]
    permission_denied! unless can? :manage, @project
    ([@commit] + @commit.all_children).each &:rerun_test_suites
    redirect_to :back, notice: "Test suites have been scheduled to rerun"
  end
end
