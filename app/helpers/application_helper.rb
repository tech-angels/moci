module ApplicationHelper

  def link_to_p(name, url_params)
    if @project
      link_to name, url_params.merge(:project_name => @project)
    else
      link_to name, url_params
    end
  end

end
