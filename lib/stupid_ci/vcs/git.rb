
module StupidCI
  module VCS
    class Git

      def initialize(dir)
        @g = ::Git.open(dir, :log => Logger.new(STDOUT))
      end

      #FIXME useful for debugging, delete me later
      def g
        @g
      end

      def up_to_date?
        #TODO proper branch
        @g.log.between('HEAD','master').map.size == 0
      end

      def move_forward
        unless up_to_date?
          @g.checkout(@g.log.between('HEAD','master').map[-1].sha)
        end
      end

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

    end
  end
end
