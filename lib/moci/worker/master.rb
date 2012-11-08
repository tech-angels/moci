module Moci
  module Worker
    # Master worker job is to manage all slave workers on given machine.
    # In case some worker would die or stop responding (should not happen in theory),
    # it's master worker responsibility to kill it or start again.
    # Sending SigINT to master worker stops all slave workers and then master,
    # but easier way to achieve that is jus using rake workers:stop
    class Master < Base

      def start
        ActiveRecord::Base.establish_connection
        number_of_workers.times do
          fork do
            ActiveRecord::Base.establish_connection
            Process.daemon(true)
            Worker::Slave.new.start
          end
        end

        monitor_slaves
      end

      protected

      def monitor_slaves
        loop do
          sleep 1
          # here goes slaves monitoring
        end
      end

      def number_of_workers
        Moci.config[:number_of_workers]
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
        sleep 4 # IMPROVE no need for waiting if they are dead
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
