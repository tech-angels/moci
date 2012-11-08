module Moci
  module Worker
    # Master worker job is to manage all slave workers on given machine.
    # In case some worker would die or stop responding (should not happen in theory),
    # it's master worker responsibility to kill it or start again.
    # Sending SigINT to master worker stops all slave workers and then master,
    # but easier way to achieve that is jus using rake workers:stop
    class Master < Base

      def start
        number_of_workers.times { start_slave }
        monitor_slaves
      end

      protected

      def monitor_slaves
        loop do
          begin
            sleep 30

            # check for zombies
            ::Worker.slave.dead.each do |worker|
              if process_alive?(worker.pid) && process_name(worker.pid).match(/moci worker/)
                Moci.report_error "moci slave worker found alive but not reporting #{worker.attributes.inspect}", 'worker'
                process_kill(worker.pid)
              else
                Moci.report_error "looks like some moci slave worker died #{worker.attributes.inspect}", 'worker'
              end
              worker.destroy
            end

            # or maybe we need some more?
            (number_of_workers - ::Worker.slave.alive.count).times { start_slave }

          # whatever happens in the loop, we want to keep it going
          rescue Exception => e
            # unless we are shutting down
            raise e if e.kind_of?(SignalException) || e.kind_of?(Interrupt)
            Moci.report_error e, :worker
            # unless it was interrupt
          end
        end
      end

      def number_of_workers
        Moci.config[:number_of_workers]
      end

      def start_slave
        ActiveRecord::Base.establish_connection
        fork do
          ActiveRecord::Base.establish_connection
          Process.daemon(true)
          Worker::Slave.new.start
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
