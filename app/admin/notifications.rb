ActiveAdmin.register Notification do
  filter :name

  index do
    column :id
    column :name
    column :notification_type, :as => :select, :collection => Moci::Notificator.types
    default_actions
  end

  form do |f|
    f.inputs "General" do
      f.input :name
      f.input :notification_type, :as => :select, :collection => Moci::Notificator.types
    end

    f.dynamic_options

    f.inputs "Enabled on projects" do
      f.input :projects, :as => :check_boxes
    end

    f.buttons
  end

  show do
    attributes_table do
      row :id
      row :name
      row :notification_type
      row :options do
        raw display_options(resource)
      end
      row :created_at
      row :updated_at
    end
  end

  # Used when changing notification_type to dynamically render apropriate option fields
  collection_action :option_fields do
    @notification = Notification.find_by_id(params[:id]) || Notification.new
    @notification.notification_type = params[:type]
    render :inline => "<%= raw(form_for(@notification, :url => '', :builder => ActiveAdmin::FormBuilder) {|f| f.dynamic_options } ) %>"
  end

end
