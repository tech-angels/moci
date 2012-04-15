source 'http://rubygems.org'

gem 'rails', '3.2.3'

# users authentication
gem 'devise'
# users authorization
gem 'cancan'

# models annotations
gem 'annotator'

# live web notifications in rails
gem 'juggernaut'

# test runner
gem 'open4'

# DB

gem 'sqlite3'
gem 'pg'

# UI

gem 'coffee-rails'
gem 'jquery-rails'
gem "haml-rails"
gem 'gravtastic' # avatars from gravatar
gem 'kaminari' # pagination

# VCS

gem 'git'

# Notifications

gem 'httparty'

# Test suite

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-mocks'
  if RUBY_VERSION.include?('1.9')
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
  gem 'faker'
  gem 'factory_girl_rails'
  gem 'ZenTest'
  gem 'sql_queries_count'
end
