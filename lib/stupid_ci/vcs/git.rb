
module StupidCI
  module VCS
    class Git

      def initialize(dir)
        @g = ::Git.open(dir, :log => Logger.new(STDOUT))
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
