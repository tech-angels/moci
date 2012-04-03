FactoryGirl.define do
  factory :test_suite_run do
    commit
    test_suite
    state 'running'
  end
end
