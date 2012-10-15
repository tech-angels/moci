module CommitsHelper
  def build_state_label(state)
    label_class = case state
      when 'ok'
        'label-warning'
      when 'clean'
        'label-success'
      when /fail|preparation_failed|failed_to_run/
        'label-important'
      when 'running'
        'label-info'
      when 'pending'
        ''
      end
    content_tag(:span, class: 'label ' + label_class) do
      state.upcase
    end
  end
end
