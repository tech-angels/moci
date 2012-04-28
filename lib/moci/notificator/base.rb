module Moci
  module Notificator

    # Notificator interface
    class Base

      extend DynamicOptions::Definition

      # TODO Plan some nice API.
      # By default things like commit_built could use methods like #message or #short_message
      # So to add new basic notificator, it would be enough for class to respond to #massage for example.
      # Plugging to commit_built on the other hand gives more possibilities, like for example playing different
      # sounds when using campfile

      def initialize(options)
        @options = options
      end

      # Fired after all test suites for given commit finish for the first time
      def commit_built(commit)
      end

      def default_options
        {}
      end

      # TODO let's make it optional and call it from default commit_built if class responds to it?
      # def message(str)
      # end

      # TODO let's make it optional and call it from default commit_built if class responds to it?
      # def short_message(str)
      # end

    end

  end
end
