
module Moci
  module VCS
    class Git < Base

      def initialize(project_instance)
        @project_instance = project_instance
        @project = project_instance.project
        @g = ::Git.open(@project_instance.working_directory)# , :log => Logger.new(STDOUT))
      end

      #FIXME useful for debugging, delete me later
      def g
        @g
      end

      # Update repository by fetching new commits
      def update
        got_commit_number current_number
        @g.fetch rescue nil # FIXME better handling
        #@g.merge("origin/#{@project.vcs_branch_name}")
        # IMPROVE simplified branch handling
        @g.log.between('HEAD',"origin/#{branch_name}").map(&:sha).reverse_each do |sha|
          got_commit_number sha
        end
      end

      # Currently checked out commit SHA
      def current_number
        @g.revparse('HEAD')
      end

      # Return hash with details for given commit SHA
      def details(number)
        c = @g.gcommit(number)
        {
          :number => @g.revparse(number),
          :author_name => c.author.name,
          :author_email => c.author.email,
          :committed_at => c.date,
          :description => c.message,
          :parents => c.parents.map(&:sha)
        }
      end

      def default_branch_name
        'master'
      end

      protected

      # Checkout commit with given SHA
      def checkout_number(sha)
        @g.checkout(sha, :force => true)
      end

    end
  end
end
