require 'capistrano/ext/multistage'
require 'capistrano-helpers/git'
require 'capistrano-helpers/shared'

# RVM
set :rvm_path,          '/usr/local/rvm'
set :rvm_bin_path,      '/usr/local/rvm/bin'
require 'rvm/capistrano'

# Set ruby version to use
set :rvm_ruby_string, 'ruby-1.9.3-p194@moci'
set :rvm_type, :system
set :using_rvm, true

# Campfire notifications
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
role :db,  main_server, primary: true
set :application,     'moci'
set :user,            'deploy'
set :group,           'www-data'
set :repository,      'git@github.com:tech-angels/moci.git'
set :ssh_options,     { :forward_agent => true }
set :stages,          %w(production)
set :default_stage,   'production'
set :use_sudo,        false

# ==============================================================================
# Server Settings
# ==============================================================================

set :app_server,      'unicorn'

# ==============================================================================
# # Restore shared files
# ==============================================================================

require 'capistrano-helpers/shared'
set :shared, %w(config/database.yml config/moci.yml)

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
  desc "Restart the moci worker"
  task :restart do
    run "sudo monit restart prod-moci-worker"
  end
end

# Database migration on deploy
after "deploy:update", "deploy:migrate"

# Clean up old releases after deployments.
after "deploy", "deploy:cleanup"
