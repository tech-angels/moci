module Moci
  module TestRunner
    class RailsUnits < Base

      # TODO: maybe try some implementing some test runner to avoid parsing
      # However parsing is safer in case when some other gems modified tests runner internals (which happens)
      # TODO: error messages parsing
      def run
        t0 = lt = Time.now
        output = ""

        exitstatus = execute("rake test:#{test_type} TESTOPTS=\"-v\"") do |pid, stdin, stdout, stderr|
          running = false

          pipe = stdout
          pipe.sync = true ### you can do this once
          buf = ''

          while c = pipe.getc
            buf << c
            output << c

            # Test suite start
            if buf.match(/# Running tests:$/)
              Rails.logger.debug("Found suite start line: #{buf}")
              buf = ''
              push :loading_time, Time.now - t0
              running = true
            end

            # Test suite finished
            if buf.match(/Finished in (.*?) seconds\./)
              Rails.logger.debug("Found finished line: #{buf}")
              running = false
            end

            # Single test run line
            if running && m = buf.match(/(.*)#(.*) = \d+\.\d+ s = (.)/)
              Rails.logger.debug("Found single test line: #{buf}")
              push_test m[2], m[1]

              buf = ''
              run_time = Time.now - lt
              lt = Time.now
              result = %w(. E F).include?(m[3]) ? m[3] : 'U'
              last_test result, run_time
            end

            # Summary line
            if m = buf.match(/(\d+?) tests, (\d+?) assertions, (\d+?) failures, (\d+?) errors/)
              Rails.logger.debug("Found summary line: #{buf}")
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

