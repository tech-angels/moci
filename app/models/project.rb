require 'tempfile'
class Project < ActiveRecord::Base
  validates_presence_of :name

  has_many :commits
  has_many :test_suites

  def vcs
    #TODO: VCS type
    Moci::VCS::Git.new self
  end

  def run_test_suites(rerun = false)
    test_suites.each do |suite|
      if rerun || head_commit.test_suite_runs.where(:test_suite_id => suite.id).count == 0
        suite.run
      end
    end
  end

  def ping
    vcs.update
    commit = head_commit
    commit.checkout
    commit.prepare
    run_test_suites
    did_something = false
    while head_commit != newest_commit
      commit = head_commit.next
      raise "head_commit != newest_commit && head has no next" unless commit
      commit.checkout
      commit.prepare
      run_test_suites
      did_something = true
    end
    return did_something
  end

  def execute(command)
    # See https://gist.github.com/973177 for comment about BUNDLE_GEMFILE
    # redirection to file to avoid using ruby tricks to get both return status
    # and output. If there's any better way please fix.
    temp_file = Tempfile.new('execute.log')
    system("cd #{working_directory} && BUNDLE_GEMFILE=\"Gemfile\" #{command} 2>&1 >#{temp_file.path}") or raise "failed to execute '#{command}'"
    output = File.read(temp_file.path)
    temp_file.unlink
    output
  end

  def prepare_env(commit)
    #TODO this is rails specific, and not even works for every app (eg  2.x)
    if commit.prepared?
      execute("bundle install")
      File.open("#{working_directory}/db/development_structure.sql",'w') do |f|
        f.puts commit.dev_structure
      end
    else
      commit.preparation_log = execute("bundle install")
      commit.preparation_log += execute("rake db:migrate")
      commit.preparation_log += execute("rake db:structure:dump")
      commit.dev_structure = File.read("#{working_directory}/db/development_structure.sql")
      commit.save!
    end
  end

  def head_commit
    commits.find_by_number(vcs.current_number)
  end

  def newest_commit
    commits.order('committed_at DESC').first
  end

end
