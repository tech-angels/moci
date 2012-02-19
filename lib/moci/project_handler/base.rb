module Moci
  module ProjectHandler

    # ProjectHandler interface
    class Base

      def initialize(project_instance)
        @project_instance = project_instance
      end

      # Executed before each test suite run
      def prepare_env(commit)
      end

      # Executed before test suite run, that is run for the first time within given ProjectInstance
      # Note that unless you do it, prepare_env will not be called
      def prepare_env_first_time(commit)
        prepare_env(commit)
      end

      # You can use it to wrap execute method
      # #TODO update this method API
      def execute_wrapper(command, output='')
        yield(command, output)
      end

      protected

      def working_directory
        @project_instance.working_directory
      end

      def execute(command, output='')
        @project_instance.execute(command, output)
      end

      def execute!(command, output='')
        @project_instance.execute!(command, output)
      end

    end

  end
end
