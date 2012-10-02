load 'deploy'

# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'
Dir['vendor/gems/*/recipes/*.rb', 'vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

# remove this line to skip loading any of the default tasks 
load 'config/deploy'
