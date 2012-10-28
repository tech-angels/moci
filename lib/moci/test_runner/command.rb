module Moci
  module TestRunner

    # Simplest runner to execute arbitrary commands
    # It only cares about exit code
    class Command < Base

      define_options do
        o :command,      "Command to execute, which exit code is taken as a result", :required => true
        o :pre_command,  "Optional command to execute before"
        o :post_command, "Optional command to execute after (no matter what result was)"
      end

      def run
        t0 = Time.now
        output = ''
        execute(options['pre_command'], output) unless options['pre_command'].blank?
        exitstatus = execute(options['command'], output)
        execute(options['post_command'], output) unless options['post_command'].blank?
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
