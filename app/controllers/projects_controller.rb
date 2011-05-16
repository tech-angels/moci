class ProjectsController < ApplicationController
  def show
    must_be_in_project
  end

  def choose
  end
end
