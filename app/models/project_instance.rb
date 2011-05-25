class ProjectInstance < ActiveRecord::Base
  belongs_to :project

  scope :free, :conditions => {:locked_by => nil}

  # Checkout given commit
  def checkout(commit)
    info "Checking out #{commit.short_number}"
    vcs.checkout commit
  end

  # Execute shell command within project instance directory
  # Returns output of the command, raises if return exit code != 0
  # TODO: Consider returning exit code and putting output in second argument
  def execute(command)
    # redirection to file to avoid using ruby tricks to get both return status
    # and output. If there's any better way please fix.
    temp_file = Tempfile.new('execute.log')
    command = "cd #{working_directory} && BUNDLE_GEMFILE=\"Gemfile\" bundle exec #{command} &> #{temp_file.path}"
    Bundler.with_clean_env do
      info " executing #{command}"
      system(command) or raise "failed to execute '#{command}' ret: #{temp_file.read}"
    end
    output = File.read temp_file.path
    temp_file.unlink
    return output
  end

  # Currently checked out commit
  def head_commit
    project.commits.find_by_number vcs.current_number
  end

  # Check for updates and run test suites if needed
  def ping
    info "PING received"
    vcs.update
    loop do
      if prepare_env head_commit
        run_test_suites
      end
      break unless head_commit.next
      checkout head_commit.next
    end
  end

  # Prevare project so that tests can be run for given commit.
  def prepare_env(commit)
    info "Preparing env for #{commit.short_number}"
    # Older commits should always be prepared first
    prepare_env(commit.parent) if commit.parent && !commit.parent.prepared?
    #TODO this is rails specific, and not even works for every app (eg  2.x)
    begin
      if commit.prepared?
        puts "EXEC BUNDLE"
        # FIXME error handling
        begin
          execute("bundle check")
        rescue
          execute("bundle install")
        end
        execute("rm -f log/test.log")
        File.open("#{working_directory}/db/development_structure.sql",'w') do |f|
          f.puts commit.dev_structure
        end
      else
        info " first time setup for #{commit.short_number}"
        puts "EXEC BUNDLE"
        commit.preparation_log = execute("bundle install")
        puts "EXEC MIGRATE"
        commit.preparation_log += execute("rake db:migrate")
        commit.preparation_log += execute("rake db:structure:dump")
        commit.dev_structure = File.read("#{working_directory}/db/development_structure.sql")
        commit.save!
      end
    rescue Exception => e
      commit.preparation_log = 'FAIL'
      commit.save!
      puts "FIXME TODO FAILURE: #{e.to_str}"
    end
    true
  end

  # Run all test suites.
  # By default onle these test suites are run which were never run for current
  # commit. If parameter is given then
  # - if it's true all suites are run
  # - if it's a number(N) those suites will be run that were run less than N times
  def run_test_suites(rerun = false)
    run_anything = false
    project.test_suites.each do |suite|
      count = head_commit.test_suite_runs.where(:test_suite_id => suite.id).count
      rerun = (count < rerun) if rerun.kind_of? Fixnum
      if rerun || count == 0
        run_anything = true
        info "running test suite #{suite.name}"
        suite.run(self)
      end
    end
    return run_anything
  end

  # Try to lock instance if it's free
  def try_to_acquire(handle)
    info "trying to acquire by #{handle}"
    # Since it's done within single query, database guarantees that lock won't
    # be given twice
    success = self.class.update_all(
      {:locked_by => handle},
      {:locked_by => nil, :id => self.id}) == 1
    info "ACQUIRED by #{handle}" if success
    return success
  end

  # Take off the lock
  def free!
    self.update_attributes!(:locked_by => nil)
  end

  # Instance of Version Control System class associated with this Project
  def vcs
    #TODO:VCS type
    Moci::VCS::Git.new self
  end

  protected

  def info(msg)
    Moci.build_logger.info "In instance #{project.name}##{self.id}: #{msg}"
  end

end
