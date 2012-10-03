module Moci
  module TestRunner

    # Rspec runner for rails applications.
    # When running specs within rails applications, it's convinient to use rake spec:* tasks, that also prepare environment.
    # Currently two options are supporterd: (IMPROVE the naming, it's not nice)
    # * specs - type of specs to run e.g. "models" to run rake spec:models
    # * spec - SPEC variable to pass, e.g. "spec/my_weird_tests"
    #
    class RailsSpec < Spec
      define_options do
        o :specs, 'Specs type to run e.g. models, it will be run like: rake spec:YOUR_VALUE'
        o :spec, 'You can use it instead of or with "specs" option, to provide specific directory'\
                 ' with specs e.g. "spec/acceptance", it will be run like: rake spec SPEC=YOUR_VALUE'
      end

      def command
        formatter_path = File.expand_path File.join(Rails.root,'lib','rspec','moci_formatter.rb')
        spec_opts = options['specs'].blank? ? "" : ":#{options['specs']}"
        specs_opts = options['spec'].blank? ? "" : "SPEC=#{options['spec']} "
        "rake spec#{spec_opts} #{specs_opts} SPEC_OPTS=\"--require #{formatter_path}\""
      end

    end
  end
end
