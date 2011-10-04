class ProjectInstance < ActiveRecord::Base
  belongs_to :project

  has_many :project_instance_commits
  alias commits project_instance_commits

  scope :free, :conditions => {:locked_by => nil}

  # Checkout given commit
  def checkout(commit)
    info "Checking out #{commit.short_number}"
    vcs.checkout commit
  end

  # Execute shell command within project instance directory
  # Output parameter can be used to pass a string where output will be appended.
  # Returns true if exit code was 0
  def execute(command, output='')
    # redirection to file to avoid using ruby tricks to get both return status
    # and output. If there's any better way please fix.
    temp_file = Tempfile.new('execute.log')
    command = "[[ -s \"$HOME/.rvm/scripts/rvm\" ]] && . \"$HOME/.rvm/scripts/rvm\" && rvm use 1.8.7 && cd #{working_directory} && BUNDLE_GEMFILE=\"Gemfile\" #{command} &> #{temp_file.path}"
    exit_status = nil
    info " executing #{command}"
    Bundler.with_clean_env do
      exit_status = system(command)
    end
    output << "$ #{command}"
    output << File.read(temp_file.path)
    temp_file.unlink
    exit_status
  end

  def execute!(command, output='')
    execute(command, output) or raise "executing command #{command} failed with output: #{output}"
  end

  # Currently checked out commit
  def head_commit
    project.commits.find_by_number vcs.current_number
  end

  # TODO: some more human friendly names would be nice
  def name
    "#{project.name} ##{self.id}"
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
    checkout commit

    pi_commit = commit.in_instance(self) #FIXME architect it better

    # Older commits should always be prepared first
    prepare_env(pi_commit.parent.commit) if pi_commit.parent && !pi_commit.parent.prepared?

    #TODO this is rails specific, and not even works for every app (eg  2.x)
    output = ''
    if pi_commit.prepared?

      # check if there really is need for bundle install
      unless execute "bundle check"
        execute! "bundle install", output
      end

      # save some gigabytes
      execute! "rm -f log/test.log"

      # put development_structure for given version in place
      File.open("#{working_directory}/db/development_structure.sql",'w') do |f|
        f.puts pi_commit.data[:dev_structure]
      end

    else

      info " first time setup for #{commit.short_number}"

      if execute("bundle install", output) && execute("bundle exec rake db:migrate", output) && execute("bundle exec rake db:structure:dump" , output)
        pi_commit.preparation_log = output
        pi_commit.state = 'prepared'
        pi_commit.data = {
          :dev_structure => File.read("#{working_directory}/db/development_structure.sql")
        }
        pi_commit.save!
      else
        pi_commit.preparation_log = output
        pi_commit.state = 'preparation_failed'
        pi_commit.save!
        raise "commit preparation failed for pi_commit##{pi_commit.id}"
        #return false
      end

    end
    true
  end

  def prepared_for?(commit)
    pic = commit.in_instance(self) && pic.prepared?
  end

  # Run all test suites.
  # By default onle these test suites are run which were never run for current
  # commit. If parameter is given then
  # - if it's true all suites are run
  # - if it's a number(N) those suites will be run that were run less than N times
  def run_test_suites(rerun = false)
    return false if head_commit.skipped?
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
