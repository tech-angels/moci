module Moci
  class Worker

    attr_accessor :model

    def initialize
      register
      monitoring_loop
      Signal.trap("EXIT") do
        unregister
        exit 0
      end

      @id = "worker:#{Process.pid}"

    end

    def to_s
      "#<Moci::Worker:ID#{@model.try :id}:PID#{Process.pid}>"
    end

    # TODO As commented within method, this is to be rewritten using queue
    def work
      # TODO instead of updated_at use something like
      # last_checked_at + check_frequency
      loop do

        # Updates, makes sure all commits are built
        Project.where('updated_at < ?', Time.now - 3.minutes).each do |project|
          project.acquire_instance(@id) do |instance|
            update_state :working
            instance.ping
          end
        end

        # Looking for randomness (optional?), do these commits some more times
        # TODO: we really need queue checking all this is way to heavy
        # FIXME I mean it, like below it really really sucks
        Project.all.each do |project|
          project.acquire_instance(@id) do |instance|
            project.commits.order('committed_at DESC').limit(10).each do |commit|
              unless commit.skipped?
                update_state :working
                instance.checkout commit
                if instance.prepare_env commit
                  break if instance.run_test_suites(4) # target number of commit builts
                end
              end
            end
          end
        end
        update_state :idle
        sleep 60
      end
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
        worker_type: :slave
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
