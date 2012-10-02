require 'capistrano/ext/multistage'
require 'capistrano-helpers/git'
require 'yaml'
require 'pathname'

# RVM
set :rvm_path,          '/usr/local/rvm'
set :rvm_bin_path,      '/usr/local/rvm/bin'
require 'rvm/capistrano'

# Set ruby version to use
set :rvm_ruby_string, 'ruby-1.9.3-p194@moci'

# Campfire notifications
# $: << File.join(File.dirname(__FILE__),'..')
# require 'lib/dev_helpers/campfire_deploy_notif'
require 'capistrano-helpers/campfire'
set :campfire_config, "#{ENV['HOME']}/.moci.yml"

# Use bundler with capistrano
require 'bundler/capistrano'

# Keep only the 5 releases
set :keep_releases, 5
after "deploy:update", "deploy:cleanup"

# ==============================================================================
# Application Settings
# ==============================================================================

role :app, main_server
role :web, main_server
set :application,     'moci'
set :user,            'deploy'
set :group,           'www-data'
set :repository,      'git@github.com:tech-angels/moci.git'
set(:deploy_to)       { "/var/www/#{application}/#{stage}" }
set(:shared_path)     { "/var/www/#{application}/#{stage}/shared" }
set :ssh_options,     { :forward_agent => true }

set :stages,          %w(production)
set :default_stage,   'production'

set :use_sudo,        false
set :sudo_prompt,     ''

# ==============================================================================
# Server Settings
# ==============================================================================

set :app_server,      'unicorn'

# ==============================================================================
# # Restore shared files
# ==============================================================================

require 'capistrano-helpers/shared'
set(:shared) { ["config/environments/#{stage}.yml", "config/database.yml", "config/moci.yml"] }

# ==============================================================================
# Unicorn
# ==============================================================================

# Originally copied from smtlaissezfaire / cap_unicorn
namespace :unicorn do
  desc "Restart unicorn"
  task :restart do
    run "oldpid=$(cat /var/www/#{application}/#{stage}/shared/pids/unicorn.pid) && kill -s USR2 $oldpid && echo 'Searching for newly spawned master process...' && until (pid=$(cat /var/www/#{application}/#{stage}/shared/pids/unicorn.pid 2>/dev/null) && test '$pid' != '$oldpid' && ps x |grep $pid|grep master) ; do sleep 1 ; done && kill -s WINCH $oldpid && kill -s QUIT $oldpid"
  end
end

namespace :deploy do
  desc "Restart the unicorn workers"
  task :restart do
    unicorn.restart
  end
end

# ==============================================================================
# Clean up old releases after deployments.
# ==============================================================================
after "deploy", "deploy:cleanup"
