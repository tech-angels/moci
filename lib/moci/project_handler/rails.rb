module Moci
  module ProjectHandler

    # Handler for rails projects
    # TODO this is was mostly thinking about rails 3+, we should add compatibility for older versions too
    # Options: (project_instance.options[:rails]
    # * db_structure_dump - should database structure be preseverved between commits (default true)
    # * rvm - if set, it is assummed rvm with given ruby version is installed, and it will be used
    #         for all commands executed within project instance (example value: 1.8.7@moci)
    # * bundler - if true, means project is using bundler (default true)
    class Rails < Base

      def execute_wrapper(command, output='')
        if options[:bundler]
          command = "bundle exec #{command}" unless command.match(/bundle (install|check|exec)/)
          command = "BUNDLE_GEMFILE=\"Gemfile\" && #{command}"
        end

        if options[:rvm]
          # It totally sucks that we have to load bash just for RVM
          # TODO: http://beginrescueend.com/workflow/scripting/ (use global installation if present
          # TODO we should check if ruby is installed first, and raise some exceptions
          command = "bash -c 'source \"$HOME/.rvm/scripts/rvm\" && rvm #{options[:rvm]} && #{command}'"
        end

        Bundler.with_clean_env { yield(command, output) }
      end

      def prepare_env(commit)
        output = ''

        if options[:bundler]
          execute! "bundle install", output unless execute "bundle check"
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

        preparation_ok = ( !options[:bundler] || execute("bundle install", output) ) &&
          execute("rake db:migrate", output) &&
          (!options[:db_structure_dump] || execute("rake db:structure:dump" , output))

        if preparation_ok
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
          :db_structure_dump => true,
          :bundler => true
        }.with_indifferent_access
      end

    end
  end
end
