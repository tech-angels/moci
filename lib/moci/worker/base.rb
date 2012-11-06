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
        @model.destroy
      end

      def monitoring_loop
        Thread.new do
          loop do
            begin
              sleep ::Worker::PING_FREQUENCY
              @model.update_attribute :last_seen_at, Time.now
            rescue Exception => e
              puts e.inspect
              # TODO organize some logging for worker
            end
          end
        end
      end
    end
  end
end
