FactoryGirl.define do
  factory :project_instance do
    project
    sequence(:working_directory) {|n| "#{Rails.root}/tmp/spec_run/#{n}" }
    after_create do |o|
      # cleaned up in test_helper
      FileUtils.mkdir_p o.working_directory
    end
  end
end
