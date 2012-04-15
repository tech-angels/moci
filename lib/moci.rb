require 'config_file'

# Require all moci modules to know which one are available
Dir.glob(File.join(Rails.root,'lib','moci','**','*.rb')).each { |rb| require rb }

module Moci

  # IMPROVE: consider keeping config options in database, this way it will be easier
  # to create step by step setup (assuming app not always may have permission to edit files in config dir)
  include ConfigFile
  has_config 'moci.yml', :environments => false

  def default_config
    {
      :default_timeout => 40.minutes
    }
  end

end
