module Moci
  module TestRunner
    class Unit < Base

      # TODO: maybe try some implementing some test runner to avoid parsing
      # Parsing is safer however in case some other gems modified tests already somehow though.
      # TODO: error messages parsing
      # TODO this runs it all at once, would be nice to see progress
      def run
        ret = {}
        ret[:tests] = []
        t0 = Time.now
        output = ""
        IO.popen("cd #{working_directory}; BUNDLE_GEMFILE=\"Gemfile\" TESTOPTS=\"-v\" rake test:units", 'r+') do |pipe|
           lt = Time.now
           running = false

           pipe.sync = true ### you can do this once
           buf = ''

           while c = pipe.getc
             buf << c
             output << c

             # Test suite start
             if buf.match(/Started$/)
               buf = ''
               ret[:loading_time] = Time.now - t0
               running = true
             end

             # Test suite finished
             if buf.match(/Finished in (.*?) seconds\./)
               running = false
             end

             # Single test run line
             if running && buf.match(/\):$/)
               m = buf.match(/(.*?)\((.*?)\):$/)
               ret[:tests] << {
                 :class_name => m[2],
                 :name => m[1]
               }
               push_test(m[1],m[2])
               buf = ''
               lt = Time.now
               puts "test #{m[1]}"
             end

             # Single test run line result
             if running && buf.match(/..\n$/)
               if test = ret[:tests].last
                 test[:time] = Time.now - lt
                 test[:result] = case buf
                 when/\./ then '.'
                 when /E/ then 'E'
                 when /F/ then 'F'
                 else 'U'
                 end
                 puts test[:result]
                 last_test(test[:result], test[:time])
                 buf = ''
               end
             end

             # Summary line
             if m = buf.match(/(.*?) tests, (.*?) assertions, (.*?) failures, (.*) errors/)
                 ret[:tests_count] = m[1]
                 ret[:assertions_count] = m[2]
                 ret[:failures_count] = m[3]
                 ret[:errors_count] = m[4]
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
          :finished => true
        )
        ret
      end
    end
  end

end

