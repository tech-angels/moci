# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * locked_by [string] - string handle of whoever locked the instance #TODO: add locked_at and timeouts
# * project_id [integer] - belongs_to Project
# * state [string, default=new] - TODO: document me
# * updated_at [datetime] - last update time
# * working_directory [string] - directory of the project we run tests on
class ProjectInstance < ActiveRecord::Base
  belongs_to :project

  has_many :project_instance_commits
  has_many :test_suite_runs

  alias commits project_instance_commits

  scope :free, :conditions => {:locked_by => nil}

  # Checkout given commit
  def checkout(commit)
    info "Checking out #{commit.short_number}"
    vcs.checkout commit
  end

  # Execute shell command within project instance directory
  #
  # output parameter can be used to pass a string where output will be appended.
  # if block is passed, output is not collected and block will receive 4 params same as for popen4:
  #   pid, stdin, stdout, stderr
  # Returns true if exit code was 0
  def execute(command, output='')
    # redirection to file to avoid using ruby tricks to get both return status
    # and output. If there's any better way please fix.
    command = "cd #{working_directory} && #{command}"
    exit_status = nil
    project_handler.execute_wrapper(command, output) do |command, output|
      info " executing #{command}"
      output << "$ #{command}\n\n" # I don't like it, but it here, but it's very useful information to know why it failed
      status = Open4.popen4(command) do |pid, stdin, stdout, stderr|
        if block_given?
          yield(pid, stdin, stdout, stderr)
        else
          # IMPROVE: separate them?
          output << stdout.read
          output << stderr.read
        end
      end
      exit_status = status.exitstatus
    end
    return exit_status == 0
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
      if !head_commit.skipped? && prepare_env(head_commit)
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

    if pi_commit.prepared?
      project_handler.prepare_env pi_commit
    else
      info " first time setup for #{commit.short_number}"
      if project_handler.prepare_env_first_time pi_commit
        pi_commit.state = 'prepared'
        pi_commit.save!
      else
        pi_commit.state = 'preparation_failed'
        pi_commit.save!
        raise "commit preparation failed for pi_commit##{pi_commit.id}"
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
    update_count = self.class.update_all(
      {:locked_by => handle},
      {:locked_by => nil, :id => self.id})
    success = (update_count == 1)

    if success
      self.reload # update locked_by field
      info "ACQUIRED by #{handle}"
    end

    return success
  end

  # Take off the lock
  def free!
    self.update_attributes!(:locked_by => nil)
  end

  # Instance of Version Control System class associated with this Project
  def vcs
    # TODO add validation in model for proper vcs_type
    @vcs ||= (
      require "moci/vcs/#{project.vcs_type.snake_case}"
      Moci::VCS.const_get(project.vcs_type.camelize).new(self)
    )
  end

  def project_handler
    # TODO add validation in model for proper project_type
    @project_handler ||= (
      require "moci/project_handler/#{project.project_type.snake_case}"
      Moci::ProjectHandler.const_get(project.project_type.camelize).new(self)
    )
  end

  protected

  def info(msg)
    Moci.build_logger.info "In instance #{project.name}##{self.id}: #{msg}"
  end

end
