module Moci
  module Worker
    class Base
      attr_accessor :model

      def initialize
        register
        monitoring_loop
        Signal.trap("EXIT") do
          safe_quit
          exit 0
        end
        $0 = "moci worker #{worker_type}"
        @id = "#{self.class}:#{Process.pid}"
      end

      def safe_quit
        unregister
      end

      def to_s
        "#<#{self.class}:ID#{@model.try :id}:PID#{Process.pid}>"
      end

      def worker_type
        raise "not implemented"
      end

      protected

      def update_state(state)
        @model.update_attribute :state, state
      end

      def register
        @model = ::Worker.create(
          pid: Process.pid,
          last_seen_at: Time.now,
          state: 'idle',
          worker_type: worker_type
        )
      end

      def unregister
        @monitoring_loop.kill
        @model.destroy
      end

      def monitoring_loop
        @monitoring_loop = Thread.new do
          loop do
            begin
              sleep ::Worker::PING_FREQUENCY
              @model.update_attribute :last_seen_at, Time.now
            rescue Exception => e
              Moci.report_error e, :worker
            end
          end
        end
      end

      def process_alive?(pid)
        Process.kill 0, pid
        return true
      rescue Errno::ESRCH
        return false
      end

      def process_name(pid)
        `ps -o command #{pid}`.split("\n").last.strip
      end

      def process_kill(pid)
        # ask politely
        begin
          Process.kill 'SIGINT', pid
        rescue Errno::ESRCH
          return false
        end

        # wait 3s to die
        30.times do
          sleep 0.1
          break unless process_alive?(pid)
        end

        # -9 if still alive
        if process_alive?(pid)
          begin
            Process.kill 'SIGKILL', pid
          rescue Errno::ESRCH
            # it's fine if it was already dead
          end
        end
        return true
      end
    end
  end
end
