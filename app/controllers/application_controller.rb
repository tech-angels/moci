class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def self.within_project
    before_filter :must_be_in_project
  end

  def must_be_in_project
    @project = Project.find_by_name params[:project_name]
    unless @project
      redirect_to :action => :choose, :controller => '/projects'
      return false
    end
  end
end
