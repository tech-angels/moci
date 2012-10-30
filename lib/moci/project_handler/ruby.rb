module Moci
  module ProjectHandler

    # Handler for projects written in ruby
    # Options:
    # * rvm - if set, it is assummed rvm with given ruby version is installed, and it will be used
    #         for all commands executed within project instance (example value: 1.8.7@moci)
    # * bundler - if true, means project is using bundler (default true)
    class Ruby < Base
      define_options do
        o :bundler,  "Does this project use bundler?", :type => :boolean, :default => true
        o :rvm,      "If set, it is assummed rvm with given ruby version is installed, and it will be used"\
                     "for all commands executed within project instance (example value: 1.8.7@moci)", :name => "RVM"
      end

      def prepare_env(commit)
        output = ''

        if options[:bundler]
          execute! "bundle install", output unless execute "bundle check"
        end

        # save some gigabytes
        execute! "rm -f log/test.log"
        true
      end

      def prepare_env_first_time(commit)
        output = ''
        preparation_ok = ( !options[:bundler] || execute("bundle install", output) )
        commit.preparation_log = output
        return preparation_ok
      end

      def execute_wrapper(command, output='')
        if options[:bundler]
          command = "bundle exec #{command}" unless command.match(/bundle (install|check|exec)/)
          command = "BUNDLE_GEMFILE=\"Gemfile\" && #{command}"
        end

        if options[:rvm]
          # It totally sucks that we have to load bash just for RVM
          # TODO: http://beginrescueend.com/workflow/scripting/ (use global installation if present
          # TODO we should check if ruby is installed first, and raise some exceptions
          # TODO: Add rvm_type to dynamic options
          rvm_load = Moci.config[:rvm_source] || "$HOME/.rvm/scripts/rvm"
          command = "bash -c 'source \"#{rvm_load}\" && rvm #{options[:rvm]} && #{command}'"
        end

        Bundler.with_clean_env { yield(command, output) }
      end
    end
  end
end
