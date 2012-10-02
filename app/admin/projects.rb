ActiveAdmin.register Project do
  filter :name
  filter :vcs_type, :as => :select, :collection => Moci::VCS.types
  filter :project_type, :as => :select, :collection => Moci::ProjectHandler.types

  index do
    selectable_column
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
      f.input :vcs_type, :as => :select, :collection => Moci::VCS.types
      f.input :project_type, :as => :select, :collection => Moci::ProjectHandler.types
      f.input :public
    end

    f.inputs "Notifications" do
      f.input :notifications, :as => :check_boxes
    end

    f.dynamic_options

    f.buttons
  end

  show do
    attributes_table do
      row :id
      row :name
      row :vcs_type
      row :project_type
      row :public
      row :options do
        raw display_options(resource)
      end
      row :created_at
      row :updated_at
    end
  end

  # Used when changing vcs_type or project_type to dynamically render apropriate option fields
  collection_action :option_fields do
    @project = Project.find_by_id(params[:id]) || Project.new
    @project.vcs_type = params[:vcs_type]
    @project.project_type = params[:project_type]
    render :inline => "<%= raw(form_for(@project, :url => '', :builder => ActiveAdmin::FormBuilder) {|f| f.dynamic_options } ) %>"
  end
end
