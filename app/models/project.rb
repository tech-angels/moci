class Project < ActiveRecord::Base
  validates_presence_of :name

  has_many :commits
  has_many :test_suites

  def vcs
    #TODO: VCS type
    Moci::VCS::Git.new self
  end

  def run_test_suites
    test_suites.each do |suite|
      if head_commit.test_suite_runs.where(:test_suite_id => suite.id).count == 0
        suite.run
      end
    end
  end

  def ping
    vcs.update
    run_test_suites
    did_something = false
    while head_commit != newest_commit

      next_commit = head_commit.next
      raise "head_commit != newest_commit && head has no next" unless next_commit
      vcs.checkout next_commit
      #TODO this is not the right place for it, possibly some project type depondent calss
      # should be a better place
      execute("bundle install")
      execute("rake db:migrate")
      run_test_suites
      did_something = true
    end
    return did_something
  end

  def execute(command)
    system("cd #{working_directory} && #{command}") or raise "failed to execute '#{command}'"
  end

  def head_commit
    commits.find_by_number(vcs.current_number)
  end

  def newest_commit
    commits.order('committed_at DESC').first
  end

end
