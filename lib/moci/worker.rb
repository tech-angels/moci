module Moci
  # Just a skeleton currently
  class Worker
    def self.go
      my_id = "worker:#{Process.pid}"
      # TODO instead of updated_at use something like
      # last_checked_at + check_frequency
      loop do

        # Updates, makes sure all commits are built
        Project.where('updated_at < ?', Time.now - 3.minutes).each do |project|
          project.acquire_instance(my_id) do |instance|
            instance.ping
          end
        end

        # Looking for randomness (optional?), do these commits some more times
        # TODO: we really need queue checking all this is way to heavy
        # FIXME I mean it, like below it really really sucks
        Project.all.each do |project|
          project.acquire_instance(my_id) do |instance|
            project.commits.order('committed_at DESC').limit(5).each do |commit|
              instance.checkout commit
              instance.prepare_env commit
              break if instance.run_test_suites(4) # target number of commit builts
            end
          end
        end

        puts "loop"
        sleep 60
      end
    end
  end
end
