# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :worker do
    worker_type :slave
    pid 0
  end
end
