module ApplicationHelper

  def link_to_p(name, url_params)
    url_params.merge!(:project_name => @project.name) if @project
    link_to name, url_params, :id => (current_page?(url_params) ? 'submenu_active' : '')
  end

  def menu_li(name, url_params)
    url_params.merge!(:project_name => @project.name) if @project
    content_tag :li, :id => (current_page?(url_params) ? 'submenu-active' : '') do
      link_to name, url_params
    end
  end

end
