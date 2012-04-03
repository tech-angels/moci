FactoryGirl.define do
  factory :test_suite do
    project
    name { Faker::Name.name }
    suite_type 'Command'
    suite_options { {'command' => '/bin/true'} }
  end
end
