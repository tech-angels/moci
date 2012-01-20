module Moci
  module ProjectHandler

    # Handler for rails projects
    # TODO this is was mostly thinking about rails 3+, we should add compatibility for older versions too
    class Rails < Base

      def execute_wrapper(command, output='')
        guess_rvm = File.exist? File.join(working_directory, '.rvmrc')
        command = "[[ -s \"$HOME/.rvm/scripts/rvm\" ]] && . \"$HOME/.rvm/scripts/rvm\" && " + command if guess_rvm
        command = "BUNDLE_GEMFILE=\"Gemfile\" && #{command}"
        Bundler.with_clean_env do
          yield(command, output)
        end
      end

      def prepare_env(commit)
        output = ''
        # check if there really is need for bundle install
        unless execute "bundle check"
          execute! "bundle install", output
        end

        # save some gigabytes
        execute! "rm -f log/test.log"

        # put development_structure for given version in place
        # TODO some projects only use schema.rb, handle that
        File.open("#{working_directory}/db/development_structure.sql",'w') do |f|
          f.puts commit.data[:dev_structure]
        end

        true
      end

      def prepare_env_first_time(commit)
        output = ''
        if execute("bundle install", output) && execute("bundle exec rake db:migrate", output) && execute("bundle exec rake db:structure:dump" , output)
          commit.preparation_log = output
          commit.data = {
            :dev_structure => File.read("#{working_directory}/db/development_structure.sql")
          }
          return true
        else
          commit.preparation_log = output
          return false
        end
      end

    end
  end
end
