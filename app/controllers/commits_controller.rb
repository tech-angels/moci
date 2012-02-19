class CommitsController < ApplicationController

  def index
    must_be_in_project
    @commits = @project.commits.order('committed_at DESC').paginate(:page => params[:page], :per_page => 10)
  end

  def show
    @commit = Commit.find params[:id]
    @project = @commit.project
  end
end
