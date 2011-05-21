class CommitsController < ApplicationController

  within_project

  def index
    @commits = @project.commits.order('committed_at DESC').paginate(:page => params[:page], :per_page => 10)
  end
end
