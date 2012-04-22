ActiveAdmin.register TestSuiteRun do
  index do
    column :project
    column :test_suite
    column :state
    column :exitstatus
    column :created_at
    column :run_time
    default_actions
  end

end
