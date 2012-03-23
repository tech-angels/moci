module Moci

  # IMPROVE: consider keeping config options in database, this way it will be easier
  # to create step by step setup (assuming app not always may have permission to edit files in config dir)
  include ConfigFile
  has_config 'moci.yml', :environments => false

end
