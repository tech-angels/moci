require 'json'

module Moci
  module TestRunner

    # Spec tests runner
    # Options:
    # * spec - spec files to run in any format that is accepted by rspec
    class Spec < Base

      define_options do
        o :spec, 'You can use it instead of or with "specs" option, to provide specific directory'\
                 ' with specs e.g. "spec/acceptance", it will be run like: rake spec SPEC=YOUR_VALUE'
      end

      # It uses custom formatter from lib/moci/test_runner/rspec/moci_formatter.rb
      # to get info about single test runs as they appear
      def run
        t0 = Time.now
        output = ""
        exitstatus = execute(command) do |pid, stdin, stdout, stderr|
          stdout.sync = true

          while line = stdout.gets
            output += line

            # All moci information is within MOCI[[...]]
            if m = line.match(/MOCI\[\[(.*?)\]\]/)
              data = JSON.load(m[1]) rescue {}
              data = data.with_indifferent_access

              case data[:event]

              when "start"

              when "result"
                push_test data[:example][:name], data[:example][:group]
                last_test data[:result], data[:duration]

              when "stats"
                push(
                  :tests_count => data[:example_count],
                  :assertions_count => data[:exmaple_count], # rspec only provides "examples count"
                  :errors_count => data[:failure_count]
                )
              end
            end
          end

          # If there was any output on stderr, append it at the end
          err = stderr.read
          output += "\n\nSTDERR: #{err}" unless err.to_s.strip.empty?
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
        "rspec --require #{formatter_path} #{options['spec']}"
      end
    end
  end
end
