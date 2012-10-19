require 'timeout'

module Moci
  module TestRunner

    # Base TestRunner class. It provides basic API for all specific test runners implementations
    # All TestRunner implementations should have it in ancestors.
    class Base

      extend DynamicOptions::Definition

      define_options do
        o :headless, "Some capybara drivers will need a window server to run, even the headless ones like capybara-webkit. " \
                     "Use this option if you need your command to be run with 'xvfb-run'.#{`which xvfb-run`.blank? ? " (!!WARNING!! can't find xvfb-run in current PATH)" : ""}", type: :boolean
      end

      # Run tests according to given TestSuiteRun params
      def self.run(tr)
        new(tr).run
      end

      # Initialize runner
      def initialize(tr)
        @tr = tr
      end

      protected

      # Project directory in which tests are being run
      def working_directory
        @tr.project_instance.working_directory
      end

      def options
        @tr.test_suite.options
      end

      def execute(command, output='', &block)
        exitstatus = false
        command = headless_prepend + command # prepend xvfb-run if :headless option is set
        max_time = Moci.config[:default_timeout]
        begin
          Timeout.timeout(max_time) do
            exitstatus = @tr.project_instance.execute(command, output, &block)
          end
        rescue Timeout::Error
          output << "\nTimeout::Error"
          push :finished => true, :output => output, :run_time => max_time, :exitstatus => exitstatus
        end
        return exitstatus
      end

      # Used by implementations to push info about test results
      # Two params with key and value can be given, or one param with a hash.
      def push(name, value = nil)
        if name.kind_of? Hash
          h = name
        else
          h = {name => value}
        end
        h.each_pair do |k,v|
          case k
          when :tests_count
            @tr.tests_count = v
          when :assertions_count
            @tr.assertions_count = v
          when :failures_count
            @tr.failures_count = v
          when :errors_count
            @tr.errors_count = v
          when :exitstatus
            @tr.exitstatus = v
          when :run_time
            @tr.run_time = v
          when :finished
            @tr.state = 'finished'
          when :output
            @tr.run_log = v
          else
            #TODO
          end
        end
        @tr.save!
      end

      # Used by implementations to push info about new test being run
      def push_test(name, class_name)
        unit = @tr.test_suite.test_units.find_or_create_by_name_and_class_name(name, class_name)
        @last_test = tur = TestUnitRun.create!(
          :test_unit => unit,
          :test_suite_run => @tr,
          :result => 'W'
        )
      end

      # Used by implementations to push info about last test result and run time
      def last_test(result, time = nil)
        @last_test.update_attributes!(
          :result => result,
          :run_time => time
        )
      end

      # may be used to prepend xvfb-run command in inherited classes
      def headless_prepend
        options['headless'].blank? ? '' : 'xvfb-run '
      end

    end
  end
end

