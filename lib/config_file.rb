# Helper module used to provide easy config file functionality.
module ConfigFile

  def config
    self.class.config
  end

  module ClassMethods
    def has_config(filename, options={})
      @config_file_name = filename
      @config_options = options
    end

    def config
      @config ||= read_config
    end

    def config_file
      filename = File.join(Rails.root,'config',@config_file_name)
      raise "config/#@config_file_name not found!" unless File.exists?(filename)
      filename
    end

    protected

    def read_config
      hash = HashWithIndifferentAccess.new(YAML.load_file(config_file))
      hash = hash[Rails.env] unless @config_options[:environments] == false
      hash
    end

  end

  def self.included(klass)
    klass.send :extend, ClassMethods
  end

end
