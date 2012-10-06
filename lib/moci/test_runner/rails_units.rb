module Moci
  module TestRunner
    class RailsUnits < Base

      # TODO: maybe try some implementing some test runner to avoid parsing
      # However parsing is safer in case when some other gems modified tests runner internals (which happens)
      # TODO: error messages parsing
      def run
        output = ''
        t0 = Time.now
        exitstatus = execute("rake test:#{test_type} TESTOPTS=\"-v\"") do |pid, stdin, stdout, stderr|
          running = false

          stdout.sync = true ### you can do this once

          while line = stdout.gets
            output << line

            # Test suite start
            if line.match(/# Running tests:$/)
              Rails.logger.debug("Found suite start line: #{line}")
              push :loading_time, Time.now - t0
              running = true
            end

            # Test suite finished
            if line.match(/Finished in (.*?) seconds\./)
              Rails.logger.debug("Found finished line: #{line}")
              running = false
            end

            # Single test run line
            if running && m = line.match(/(.*)#(.*) = (.*) s = (.)/)
              Rails.logger.debug("Found single test line: #{line}")
              push_test m[2], m[1]

              line = ''
              run_time = m[3]
              result = %w(. E F).include?(m[4]) ? m[4] : 'U'
              last_test result, run_time
            end

            # Summary line
            if m = line.match(/(\d+?) tests, (\d+?) assertions, (\d+?) failures, (\d+?) errors/)
              Rails.logger.debug("Found summary line: #{line}")
              push(
                :tests_count => m[1],
                :assertions_count => m[2],
                :failures_count => m[3],
                :errors_count => m[4]
              )
            end
          end
          output << stderr.read
        end
        push(
          :run_time => Time.now - t0,
          :output => output,
          :exitstatus => exitstatus,
          :finished => true
        )
      end

      protected

      def test_type
        "units"
      end

    end
  end

end

