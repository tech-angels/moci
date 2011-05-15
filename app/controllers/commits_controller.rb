class CommitsController < ApplicationController

  within_project

  def index
    #TODO, pagination, project, branches
    @commits = @project.commits.order('committed_at DESC').all
  end
end
