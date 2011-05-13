class CommitsController < ApplicationController
  def index
    #TODO, pagination, project, branches
    @commits = Commit.order('committed_at DESC').all
  end
end
