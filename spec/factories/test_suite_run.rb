FactoryGirl.define do
  factory :test_suite_run do
    commit
    test_suite
    project_instance
    state 'running'
  end
end
