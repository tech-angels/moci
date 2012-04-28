ActiveAdmin.register Project do
  filter :name
  filter :vcs_type, :as => :select, :collection => Moci::VCS.types
  filter :project_type, :as => :select, :collection => Moci::ProjectHandler.types

  index do
    column :name
    column :vcs_type
    column :project_type
    column :public
    column :instances do |project|
      link_to project.instances.count, admin_project_instances_path(:q => {:project_id_eq => project.id })
    end
    default_actions
  end

  form do |f|
    f.inputs "General" do
      f.input :name
      #f.input :project_options
      f.input :vcs_type, :as => :select, :collection => Moci::VCS.types
      f.input :project_type, :as => :select, :collection => Moci::ProjectHandler.types
      f.input :public
    end

    f.inputs "Notifications" do
      f.input :notifications, :as => :check_boxes
    end

    f.buttons
  end
end
