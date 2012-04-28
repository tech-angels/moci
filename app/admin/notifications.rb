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
      f.input :notification_type
    end

    f.inputs "Enabled on projects" do
      f.input :projects, :as => :check_boxes
    end

    f.buttons
  end

end
