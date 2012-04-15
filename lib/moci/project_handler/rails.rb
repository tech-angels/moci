module Moci
  module ProjectHandler

    # Handler for rails projects
    # TODO this is was mostly thinking about rails 3+, we should add compatibility for older versions too
    # Options: (project_instance.options[:rails]
    # * db_structure_dump - should database structure be preseverved between commits (default true)
    # * rvm - if set, it is assummed rvm with given ruby version is installed, and it will be used
    #         for all commands executed within project instance (example value: 1.8.7@moci)
    class Rails < Base

      def execute_wrapper(command, output='')
        command = "rvm use #{options[:rvm]} && #{command}" if options[:rvm]
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

        # put development_structure for given version in place if needed
        if options[:db_structure_dump] && commit.data[:dev_structure]
          File.open("#{working_directory}/db/development_structure.sql",'w') do |f|
            f.puts commit.data[:dev_structure]
          end
        end

        true
      end

      def prepare_env_first_time(commit)
        output = ''
        if execute("bundle install", output) && execute("bundle exec rake db:migrate", output) && (!options[:db_structure_dump] || execute("bundle exec rake db:structure:dump" , output))
          commit.preparation_log = output
          if options[:db_structure_dump] && File.exist?("#{working_directory}/db/development_structure.sql")
            commit.data = {
              :dev_structure => File.read("#{working_directory}/db/development_structure.sql")
            }
          end
          return true
        else
          commit.preparation_log = output
          return false
        end
      end

      protected

      def options
        default_options.merge(@project_instance.project.options[:rails] || {})
      end

      def default_options
        {
          :db_structure_dump => true
        }.with_indifferent_access
      end

    end
  end
end
