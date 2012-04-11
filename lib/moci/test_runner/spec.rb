module Moci
  module TestRunner

    # SPec tests runner
    # Options:
    # * specs - spec files to run in any format that is accepted by rspec
    class Spec < Base

      # This uses custom formatter from lib/moci/test_runner/rspec/moci_formatter.rb
      # to get info about single test runs
      def run
        t0 = Time.now
        running = nil
        output = ""
        exitstatus = execute(command) do |pid, stdin, stdout, stderr|
          pipe = stdout
          pipe.sync = true
          dt0 = Time.now

          while line = pipe.gets
            output += line
            line = line.strip
            if line == "START"
              dt0 = Time.now
            else
              if line.match(/^.--EX\[/)
                result, stuff = line.split('--',2)
                class_name = stuff.match(/EX\[\[(.*?)\]\]/)[1]
                name = stuff.split(']]',2).last
                push_test name, class_name
                last_test result, (Time.now - dt0)
              end
              if line.match(/^STATS:/)
                stats = line.split("STATS:",2)[1].split(',').map(&:to_f)
                push(
                  :tests_count => stats[1],
                  :assertions_count => stats[1],
                  :errors_count => stats[2]
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

      end

      def command
        formatter_path = File.expand_path File.join(File.dirname(__FILE__),'rspec','moci_formatter.rb')
        "rspec --require #{formatter_path} #{options['specs']}"
      end
    end
  end
end
