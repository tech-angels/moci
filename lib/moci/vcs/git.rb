
module Moci
  module VCS
    class Git < Base

      def initialize(project)
        @project = project
        @g = ::Git.open(@project.working_directory)# , :log => Logger.new(STDOUT))
      end

      #FIXME useful for debugging, delete me later
      def g
        @g
      end

      def update
        got_commit_number current_number
        @g.fetch rescue nil # FIXME better handling
        #@g.merge("origin/#{@project.vcs_branch_name}")
        # FIXME simplified branch handling
        @g.log.between('HEAD',"origin/#{@project.vcs_branch_name}").map(&:sha).each do |sha|
          got_commit_number sha
        end
      end

      #def up_to_date?
        ##TODO proper branch
        #@g.log.between('HEAD','master').map.size == 0
      #end

      #def latest_checked_out?
        #@g.log.between('HEAD','master').map.size == 0
      #end

      #def move_forward
        #unless up_to_date?
          #next_sha = @g.log.between('HEAD','master').map[-1].sha
          #puts "CHECKOUT: #{next_sha}"
          #@g.checkout(next_sha)
        #end
      #end

      def current_number
        @g.revparse('HEAD')
      end


      def details(number)
        c = @g.gcommit(number)
        {
          :number => @g.revparse(number),
          :author_name => c.author.name,
          :author_email => c.author.email,
          :committed_at => c.date,
          :description => c.message
        }
      end

      protected

      def checkout_number(sha)
        @g.checkout(sha)
      end

    end
  end
end
