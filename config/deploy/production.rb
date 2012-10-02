set :branch,          'master'
set :rails_env,       'production'
set :user,            'prodmoci'
set :deploy_to,       "/var/www/#{application}/#{rails_env}"
set :shared_path,     "#{deploy_to}/shared"
