module Moci
  module TestRunner

    # Simplest runner to execute arbitrary commands
    # It only cares about exit code
    # Options:
    # * command  - command to execute
    class Command < Base
      def run
        t0 = Time.now
        output = ''
        exitstatus = execute(options['command'], output)
        run_time = Time.now - t0
        push(
          :exitstatus => exitstatus,
          :run_time => run_time,
          :finished => true,
          :output => output
        )
      end
    end
  end
end
