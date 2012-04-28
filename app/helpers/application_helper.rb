module ApplicationHelper
  include DynamicOptions::View

  def link_to_p(name, url_params)
    url_params.merge!(:project_name => @project.name) if @project
    link_to name, url_params, :id => (current_page?(url_params) ? 'submenu_active' : '')
  end

  def menu_li(name, url_params)
    url_params.merge!(:project_name => @project.name) if @project
    clean_params = url_params.dup
    clean_params.delete :page
    content_tag :li, :id => (current_page?(clean_params) ? 'submenu-active' : '') do
      link_to name, url_params
    end
  end

  def bad_value(value)
    raw(value.to_i > 0 ?
      %Q{<span class="red">#{value.to_i}</span>} :
      %Q{<span class="green">#{value.to_i}</span>})
  end

  def duration(seconds)
    return '-' unless seconds
    ret = ''
    ret << "#{(seconds / 60).to_i}m&nbsp;" if seconds >= 60
    ret << "#{'%2.f' % (seconds % 60)}s" if seconds % 60 != 0
    raw ret
  end

  def link_to_longtext(name, longtext, options={})
    render :partial => '/common/longtext', :locals => {:name => name, :longtext => longtext, :options => options}
  end

end
