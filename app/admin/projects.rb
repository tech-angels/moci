ActiveAdmin.register Project do
  filter :name
  filter :vcs_type, :as => :select, :collection => Moci::VCS.types
  filter :project_type, :as => :select, :collection => Moci::ProjectHandler.types

  form do |f|
    f.inputs do
      f.input :name
      #f.input :project_options
      f.input :vcs_type, :as => :select, :collection => Moci::VCS.types
      f.input :project_type, :as => :select, :collection => Moci::ProjectHandler.types
      f.input :public
    end
    f.buttons
  end
end
