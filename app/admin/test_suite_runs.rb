ActiveAdmin.register TestSuiteRun do
  actions :all, :except => [:new]

  index do
    selectable_column
    column :project
    column :test_suite
    column :state
    column :exitstatus
    column :created_at
    column :run_time
    default_actions
  end

end
