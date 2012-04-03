module Moci
  module TestRunner

    # Simplest runner to execute arbitrary commands
    # It only cares about exit code
    # Options:
    # * *command*  - command to execute, which exit code is taken as a result
    # * pre_command - optional command to execute before
    # * post_command - optional command to execute after (no matter what result was)
    class Command < Base
      def run
        t0 = Time.now
        output = ''
        execute(options['pre_command', output) if options['pre_command']
        exitstatus = execute(options['command'], output)
        execute(options['post_command', output) if options['post_command']
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
