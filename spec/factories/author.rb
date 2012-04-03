FactoryGirl.define do
  factory :author do
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end
