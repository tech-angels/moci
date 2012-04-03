FactoryGirl.define do
  factory :commit do
    project
    author
    committed_at Time.now - 1.minute
    number { rand(10**10).to_s(32) }
  end
end
