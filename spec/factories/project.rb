FactoryGirl.define do
  factory :project do
    name { Faker::Name.name }
  end

  factory :public_project, :parent => :project do
    public true
  end
end
