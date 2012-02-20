module Moci
  module TestRunner
    class RailsUnits < Base

      # TODO: maybe try some implementing some test runner to avoid parsing
      # However parsing is safer in case when some other gems modified tests runner internals (which happens)
      # TODO: error messages parsing
      def run
        t0 = lt = Time.now
        output = ""

        exitstatus = execute("TESTOPTS=\"-v\" rake test:#{test_type}") do |pid, stdin, stdout, stderr|
           running = false

           pipe = stdout
           pipe.sync = true ### you can do this once
           buf = ''

           while c = pipe.getc
             buf << c
             output << c

             # Test suite start
             if buf.match(/Started$/)
               buf = ''
               push :loading_time, Time.now - t0
               running = true
             end

             # Test suite finished
             if buf.match(/Finished in (.*?) seconds\./)
               running = false
             end

             # Single test run line
             if running && buf.match(/\):$/)
               m = buf.match(/(.*?)\((.*?)\):$/)
               push_test m[1], m[2]
               buf = ''
               lt = Time.now
             end

             # Single test run line result
             if running && buf.match(/..\n$/) && @last_test
               run_time = Time.now - lt
               result = case buf
               when/\./ then '.'
               when /E/ then 'E'
               when /F/ then 'F'
               else 'U'
               end
               last_test result, run_time
               buf = ''
             end

             # Summary line
             if m = buf.match(/(\d+?) tests, (\d+?) assertions, (\d+?) failures, (\d+?) errors/)
               push(
                 :tests_count => m[1],
                 :assertions_count => m[2],
                 :failures_count => m[3],
                 :errors_count => m[4]
               )
             end
           end
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

