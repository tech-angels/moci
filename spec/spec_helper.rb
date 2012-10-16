require 'simplecov'
SimpleCov.start do
  add_filter "/config/"
  add_filter "/spec/"

  add_group "Libraries", "lib"
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Helpers", "app/helpers"
  add_group "Admin", "app/admin"
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'cancan/matchers'
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
  puts "test_app_skel not found, cloning from git://github.com/comboy/rails_test.git"
  system("cd #{tmp_spec} && git clone git://github.com/comboy/rails_test.git #{test_app_skel_dir} && cd #{test_app_skel_dir} && git checkout 836db4770495") || raise("failed to clone test application")
end

FileUtils.rm_rf("#{Rails.root}/tmp/spec_run") if File.exists? Rails.root

# Speed up the test suite
Rails.logger.level = 4 # fatal
Devise.stretches = 1

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

  config.include FactoryGirl::Syntax::Methods
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium

