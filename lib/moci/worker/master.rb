module Moci
  module Worker
    class Master < Base
      def initialize
        super
        ::Worker.cleanup
      end

      def start
        num_workers = 2 # TODO make it dynamic/configurable
        ActiveRecord::Base.establish_connection
        num_workers.times do
          fork do
            ActiveRecord::Base.establish_connection
            Process.daemon(true)
            Worker::Slave.new.start
          end
        end

        loop do
          sleep 1
          # here goes slaves monitoring
        end
      end

      # TODO with multi machine confirguration master should probably
      # only manage slaves on given machine (additional column in workers table)
      def stop_slaves
        slaves = ::Worker.slave.alive.all

        # ask politely
        slaves.each do |worker|
          Process.kill 'SIGINT', worker.pid
        end

        # wait
        sleep 2 # IMPROVE no need for waiting if they are dead
        slaves.each do |worker|
          begin
            Process.kill 'SIGKILL', worker.pid
          rescue Errno::ESRCH
            # it was already dead, that's fine
          end
        end
      end

      def safe_quit
        stop_slaves
        super
      end

      def worker_type
        :master
      end
    end
  end
end
