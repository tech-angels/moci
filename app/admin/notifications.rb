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

    dynamic_options f # IMPROVE, implement as formtastic module, so that we have f.dynamic_options

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


end
