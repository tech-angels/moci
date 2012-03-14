module Moci
  module TestRunner
    class RailsSpec < Spec

      def command
        formatter_path = File.expand_path File.join(File.dirname(__FILE__),'rspec','moci_formatter.rb')
        "rake spec:#{options['specs']} SPEC_OPTS=\"--require #{formatter_path}\""
      end

    end
  end
end
