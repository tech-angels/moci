class Project < ActiveRecord::Base
  validates_presence_of :name

  has_many :commits
  has_many :test_suites

  def vcs
    #TODO: VCS type
    Moci::VCS::Git.new self.working_directory
  end

  def foo
    if head = commits.find_by_number(vcs.current_number)
      commit = head
      puts "no create"
    else
      puts "creating"
      #TODO: maybe move somewhere else
      info = vcs.details(vcs.current_number)
      unless author = Author.find_by_email(info[:author_email])
        author = Author.new
        author.email = info[:author_email]
        author.name = info[:author_name]
        author.save!
      end
      commit = commits.new(
        :author => author,
        :description => info[:description],
        :committed_at => info[:committed_at],
        :number => info[:number]
      )
      commit.save!
    end

    test_suites.each do |suite|
      if commit.test_suite_runs.where(:test_suite_id => suite.id).count == 0
        suite.run
      end
    end
  end

  def boo
    unless vcs.up_to_date?
      #TODO this is not the right place for it
      vcs.move_forward
      execute("bundle install")
      execute("rake db:migrate")
      foo
      return true
    end
    return false
  end

  def boo_hoo
    loop do
      break unless boo
    end
  end

  def execute(command)
    system("cd #{working_directory} && #{command}") or raise "failed to execute '#{command}'"
  end

  def head_commit
    commits.order('committed_at DESC').last
  end

  def current_commit
    commits.find_by_number(vcs.current_number)
  end


end
