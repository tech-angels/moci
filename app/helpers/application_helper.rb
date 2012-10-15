module ApplicationHelper
  include DynamicOptions::View

  def link_to_p(name, url_params)
    link_to name, url_params, :id => (current_page?(url_params) ? 'submenu_active' : '')
  end

  def bad_value(value)
    raw(value.to_i > 0 ?
      %Q{<span class="badge badge-important">#{value.to_i}</span>} :
      %Q{<span class="badge badge-success">#{value.to_i}</span>})
  end

  def duration(seconds)
    return '-' unless seconds
    ret = ''
    ret << "#{(seconds / 60).to_i}m&nbsp;" if seconds >= 60
    ret << "#{'%2.f' % (seconds % 60)}s" if seconds % 60 != 0
    raw ret
  end

  def link_to_longtext(name, longtext, options={})
    render :partial => '/common/modal', :locals => {:name => name, :longtext => longtext, :options => options}
  end

end
