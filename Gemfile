source 'http://rubygems.org'

ruby '1.9.3'

gem 'rails', '3.2.9'

# users authentication
gem 'devise'
# users authorization
gem 'cancan'

# adimn panel
gem 'activeadmin'

# models annotations
gem 'annotator'

# live web notifications
gem 'pusher'

# test runner
gem 'open4'

# DB
gem 'sqlite3'
gem 'pg'

# UI

gem 'coffee-rails'
gem 'jquery-rails'
gem 'sass-rails'
gem "haml-rails"
gem 'gravtastic' # avatars from gravatar
gem 'kaminari' # pagination
gem 'kaminari-bootstrap' # bootstrap theme for kaminari
gem 'friendly_id'
gem "twitter-bootstrap-rails"

# VCS
gem 'git'

# notifications
gem 'tinder'

group :production do
  # Unicorn
  gem 'unicorn'
end

# test suite
group :development, :test do
  gem 'capistrano'
  gem 'capistrano-helpers'
  gem 'capistrano-ext'
  gem 'rvm-capistrano'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'rspec-mocks'
  gem 'shoulda-matchers'
  gem 'sql_queries_count'
  gem 'ZenTest'
  gem 'debugger'
end

group :test do
  # Code coverage for Ruby 1.9 https://github.com/colszowka/simplecov
  gem 'simplecov', :require => false
end
