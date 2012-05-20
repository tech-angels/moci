class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def self.within_project
    before_filter :must_be_in_project
  end

  def authenticate_admin!
    authenticate_user!
    redirect_to root_path, :alert => "You don't have have admin privileges" unless current_user.admin?
  end

  def must_be_in_project
    @project ||= projects.find_by_name params[:project_name]
    unless @project && (@project.public || user_signed_in? && can?(:view, @project))
      redirect_to({:action => :choose, :controller => '/projects'}, :alert => "Project not found")
      return false
    end
  end

  def permission_denied!
    # TODO: rescue_from and render some nice permisison denied, however there should never be link visible
    # to the action that cannot be taken
    raise "Permission denied!"
  end

  helper_method :projects
  def projects
    if user_signed_in?
      Project.where(:id => visible_projects.map(&:id))
    else
      Project.public
    end
  end

  def visible_projects
    Project.all.select { |project| project.public? || can?(:view, project) }
  end

end
