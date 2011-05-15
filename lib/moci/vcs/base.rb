module Moci
  module VCS
    class Base

      def checkout(commit)
        checkout_number(commit.number)
      end

      protected

      def got_commit_number(number)
        unless @project.commits.find_by_number(number)
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
        end
      end
    end
  end
end
