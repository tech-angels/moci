# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_permission do
    user
    project
    name 'view'
  end
end
