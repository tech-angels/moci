module Moci
  module TestRunner

    # Rspec runner for rails applications.
    # When running specs within rails applications, it's convinient to use rake spec:* tasks, that also prepare environment.
    # Currently two options are supporterd: (IMPROVE the naming, it's not nice)
    # * specs - type of specs to run e.g. "models" to run rake spec:models
    # * spec - SPEC variable to pass, e.g. "spec/my_weird_tests"
    #
    class RailsSpec < Spec

      def command
        formatter_path = File.expand_path File.join(Rails.root,'lib','rspec','moci_formatter.rb')
        "rake spec#{options['specs'] ? ":#{options['specs']}" : ""} #{options['spec'] ? "SPEC=#{options['spec']} " : ""}SPEC_OPTS=\"--require #{formatter_path}\""
      end

    end
  end
end
