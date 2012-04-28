ActiveAdmin.register TestSuite do
  filter :project
  filter :name

  index do
    column :id
    column :project
    column :name
    default_actions
  end

end
