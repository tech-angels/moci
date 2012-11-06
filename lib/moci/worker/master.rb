module Moci
  module Worker
    class Master < Base
      def start
        num_workers = 5 # TODO make it dynamic/configurable

        num_workers.times do
          pid = Process.fork
          if pid
            # TODO see if it started correctly
          else
            ActiveRecord::Base.establish_connection
            Process.daemon(true)
            Worker::Slave.new.start
          end
        end
        exit 0
      end

      def worker_type
        :master
      end
    end
  end
end
