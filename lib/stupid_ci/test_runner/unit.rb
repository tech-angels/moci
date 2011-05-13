module StupidCI
  module TestRunner
    class Unit

      # TODO: maybe try some implementing some test runner to avoid parsing
      # Parsing is safer however in case some other gems modified tests already somehow though.
      # TODO: error messages parsing
      # TODO this runs it all at once, would be nice to see progress
      def self.run(directory)
        ret = {}
        ret[:tests] = []
        IO.popen("cd #{directory}; TESTOPTS=\"-v\" rake test:units", 'r+') do |pipe|
           t0 = Time.now
           lt = Time.now
           running = false

           pipe.sync = true ### you can do this once
           buf = ''

           while c = pipe.getc
             buf << c.chr

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
                 buf = ''
               end
             end

             # Summary line
             if m = buf.match(/(.*?) tests, (.*?) assertions, (.*?) failures, (.*) errors/)
               ret[:tests_count] = m[1]
               ret[:assertions_count] = m[2]
               ret[:failures_count] = m[3]
               ret[:errors_count] = m[4]
             end
           end

        end
        ret
      end
    end
  end

end

