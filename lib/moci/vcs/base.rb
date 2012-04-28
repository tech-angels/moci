module Moci
  module VCS

    # TODO: make Base bahave like a dummy VCS, it should work for no VCS installed in the project
    # Base class that all VCS implementations should as an ancestor.
    class Base

      # VCS object is initialized separately for each project instance, once it's initialized, it operates within the same working_direcotry
      def initialize(project_instance)
        @project_instance = project_instance
        @project = project_instance.project
      end

      # Currently project is associated with only one branch, this method returns it's name
      def branch_name
        @project.options.try(:[],'vcs').try(:[], 'branch_name') || default_branch_name
      end

      # Checkout given Commit object
      # (Not commit number, but Commit model is passed)
      def checkout(commit)
        # We could know about this commit from different instance, if ProjectInstanceCommit is not found, update
        update unless pic = @project_instance.commits.find_by_commit_id(commit.id)
        checkout_number commit.number
      end

      # Returns number of currently checked out commit
      def current_number
        raise "implement me"
      end

      def default_branch_name
      end


      # Should return hash with data about commit with given number
      # Recognized keys:
      # * :number - commit number
      # * :author_name
      # * :author_email
      # * :committed_at [Time]
      # * :description
      # * :parents - array with numbers of parent commits
      def details(numbe)
        raise "implement me"
      end


      # It should update local checkout with main repository, and call .got_commit_number
      # for each new commit that was found.
      def update
        raise "implement me"
      end

      protected

      # Used by implementations to notify about new commit found.
      # Creates Commit object in database.
      def got_commit_number(number)
        unless commit = @project.commits.find_by_number(number)
          info = details(number)

          unless author = Author.find_by_email(info[:author_email])
            author = Author.new
            author.email = info[:author_email]
            author.name = info[:author_name]
            author.save!
          end

          commit = @project.commits.new(
            :author => author,
            :description => info[:description],
            :committed_at => info[:committed_at],
            :number => info[:number]
          )

          commit.save!

          if info[:parents]
            info[:parents].each do |number|
              if parent = @project.commits.find_by_number(number)
                commit.parents << parent
              end
            end
          end

        end

        unless pi_commit = @project_instance.commits.find_by_commit_id(commit.id)
          pi_commit = @project_instance.commits.new( :commit => commit )
          pi_commit.save!
        end
      end

    end
  end
end
