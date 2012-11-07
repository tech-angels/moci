namespace :workers do

  desc "Start moci workers"
  task :start => :environment do
    fork do
      ActiveRecord::Base.establish_connection
      master = Moci::Worker::Master.new
      master.start
    end
  end

  desc "Stop moci workers"
  task :stop => :environment do
    master = Worker.master.first
    Process.kill 'SIGINT', master.pid
    sleep 2.5 # IMPROVE don't wait if it was killed right away
    begin
      Process.kill 'SIGKILL', master.pid
    rescue Errno::ESRCH
      # it's fine if it was already dead
    end
  end

  desc "Start single slave worker without deamonizing (for dubugging purposes)"
  task :run_slave => :environment do # TODO: rename me? naming is hard
    Moci::Worker::Slave.new.start
  end

end
