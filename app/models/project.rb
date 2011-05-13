#require 'stupid_ci/vcs/git'
class Project < ActiveRecord::Base
  validates_presence_of :name

  has_many :commits
  has_many :test_suites

  def vcs
    #TODO: VCS type
    StupidCI::VCS::Git.new self.working_directory
  end

  def foo
    head = head_commit
    if head && vcs.current_number == head.number
      # we have it in db
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
  end

  def head_commit
    commits.order('committed_at DESC').last
  end

end
