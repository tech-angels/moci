module Moci
  module VCS
    class Base

      # Checkout given Commit object
      # (Not commit number, but Commit model is passed)
      def checkout(commit)
        update unless pic = @project_instance.commits.find_by_commit_id(commit.id)
        unless pic || @project_instance.commits.find_by_commit_id(commit.id)
          raise "could not find commit #{commit.id} on instance #{@project_instance.id}"
        end
        checkout_number(commit.number)
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
        end

        unless pi_commit = @project_instance.commits.find_by_commit_id(commit.id)
          pi_commit = @project_instance.commits.new( :commit => commit )
          pi_commit.save!
        end
      end
    end
  end
end
