FactoryGirl.define do
  factory :project_instance do
    project
    working_directory "#{Rails.root}/tmp/test_run/#{$instance_dir = $instance_dir.to_i + 1}"
    after_create do |o|
      # cleaned up in test_helper
      FileUtils.mkdir_p o.working_directory
    end
  end
end
