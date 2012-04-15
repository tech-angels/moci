
module Moci
  module TestRunner

    # SPec tests runner
    # Options:
    # * specs - spec files to run in any format that is accepted by rspec
    class Spec < Base

      require 'rspec/moci_formatter'
      include RSpec::Core::Formatters::MociFormatter::Patterns
      # It uses custom formatter from lib/moci/test_runner/rspec/moci_formatter.rb
      # to get info about single test runs as they appear
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
            if line == P_TEST_START
              dt0 = Time.now
            else
              if line.match(/^(#{Regexp.escape(P_TEST_PASSED)}|#{Regexp.escape(P_TEST_PENDING)}|#{Regexp.escape(P_TEST_FAILED)})/)
                result = line[0].chr
                class_name = line.match(/#{Regexp.escape(P_GROUP_NAME_START)}(.*?)#{Regexp.escape(P_GROUP_NAME_END)}/)[1]
                name = line.split(P_GROUP_NAME_END,2).last.strip
                push_test name, class_name
                last_test result, (Time.now - dt0)
              end
              if line.starts_with? P_STATS
                stats = line.split(P_STATS,2)[1].split(',').map(&:to_f)
                push(
                  :tests_count => stats[1],
                  :assertions_count => stats[1], # rspec only provide "examples count"
                  :errors_count => stats[2]
                )
              end
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

      def command
        formatter_path = File.expand_path File.join(Rails.root,'lib','rspec','moci_formatter.rb')
        "rspec --require #{formatter_path} #{options['specs']}"
      end
    end
  end
end
