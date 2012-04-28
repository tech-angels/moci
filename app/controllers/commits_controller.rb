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
end
