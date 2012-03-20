# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'fileutils'

Rails.backtrace_cleaner.remove_silencers!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}


# Example appliaciotns used in acceptance
#
tmp_spec = "#{Rails.root}/tmp/spec_helpers"
test_app_skel_dir = "#{tmp_spec}/test_app_skel"
$test_app_skel_dir = test_app_skel_dir

unless File.exists?(test_app_skel_dir)
  FileUtils.mkdir_p(tmp_spec)
  system("cd #{tmp_spec} && git clone git://github.com/comboy/rails_test.git #{test_app_skel_dir}") || raise("failed to clone test application")
end

FileUtils.rm_rf("#{Rails.root}/tmp/spec_run") if File.exists? Rails.root



RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end
