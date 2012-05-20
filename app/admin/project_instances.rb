ActiveAdmin.register ProjectInstance do
  menu :parent => "Projects", :label => "Instances"

  form do |f|
    f.inputs do
      f.input :project
      f.input :working_directory
    end
    
    f.buttons
  end
end
