class ProjectInstance < ActiveRecord::Base
  belongs_to :project

  scope :free, :conditions => {:locked_by => nil}

  # Checkout given commit
  def checkout(commit)
    puts "Checking out #{commit.id} #{commit.number}"
    vcs.checkout commit
  end

  # Execute shell command within project instance directory
  # Returns output of the command, raises if return exit code != 0
  # TODO: Consider returning exit code and putting output in second argument
  def execute(command)
    # See https://gist.github.com/973177 for comment about BUNDLE_GEMFILE
    bundler_fix = %Q{BUNDLE_GEMFILE="#{working_directory}/Gemfile" BUNDLE_APP_CONFIG="#{working_directory}/.bundle"}
    # redirection to file to avoid using ruby tricks to get both return status
    # and output. If there's any better way please fix.
    temp_file = Tempfile.new('execute.log')
    command = "cd #{working_directory} && #{bundler_fix} bundle exec #{command} &> #{temp_file.path}"
    #FIXME error handling
    system(command) or raise "failed to execute '#{command}' ret: #{temp_file.read}"
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
    # Older commits should always be prepared first
    prepare_env(commit.parent) if commit.parent && !commit.parent.prepared?
    #TODO this is rails specific, and not even works for every app (eg  2.x)
    begin
      if commit.prepared?
        # FIXME use bundle check
        puts "EXEC BUNDLE"
        execute("bundle install")
        File.open("#{working_directory}/db/development_structure.sql",'w') do |f|
          f.puts commit.dev_structure
        end
      else
        puts "EXEC BUNDLE"
        commit.preparation_log = execute("bundle install")
        puts "EXEC MIGRATE"
        commit.preparation_log += execute("rake db:migrate")
        commit.preparation_log += execute("rake db:structure:dump")
        commit.dev_structure = File.read("#{working_directory}/db/development_structure.sql")
        commit.save!
      end
    rescue Exception => e
      puts "FIXME TODO FAILURE: #{e.to_str}"
    end
    true
  end

  # Run all test suites.
  def run_test_suites(rerun = false)
    project.test_suites.each do |suite|
      if rerun || head_commit.test_suite_runs.where(:test_suite_id => suite.id).count == 0
        suite.run(self)
      end
    end
  end

  # Try to lock instance if it's free
  def try_to_acquire(handle)
    # Since it's done within single query, database guarantees that lock won't
    # be given twice
    self.class.update_all(
      {:locked_by => handle},
      {:locked_by => nil, :id => self.id}) == 1
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

end
