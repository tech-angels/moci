require 'config_file'

# Require all moci modules to know which one are available
Dir.glob(File.join(Rails.root,'lib','moci','**','*.rb')).each { |rb| require rb }

module Moci

  # IMPROVE: consider keeping config options in database, this way it will be easier
  # to create step by step setup (assuming app not always may have permission to edit files in config dir)
  include ConfigFile
  has_config 'moci.yml', environments: false

  def self.default_config
    {
      default_timeout: 40.minutes,
      number_of_workers: 3
    }
  end

  # Stub for some better error reporting (stored in DB in the future),
  # whatever happens this will be easier to find and replace then some
  # writes to random logs
  # * error - exception object or string
  # * options - options hash or symbol deciding error class e.g.: internal, worker, test_runner, maybe some more)
  def self.report_error(error, options=nil)
    desc = "[#{options.inspect}] "
    if error.kind_of? Exception
      desc << "#{error.message}\n\t"
      desc << error.backtrace.join("\n\t")
    else
      desc << error
    end
    error_logger.error desc
  end

  def self.error_logger
    @error_logger ||= (
      logger = Logger.new(File.join(Rails.root,'log','error.log'))
      logger.formatter = ::Logger::Formatter.new
      logger.datetime_format = "%Y-%m-%d %H:%M:%S "
      logger
    )
  end

end
