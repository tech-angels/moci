require 'rspec'
require 'rspec/core/formatters/base_text_formatter'

module RSpec
  module Core
    module Formatters
      class MociFormatter < BaseTextFormatter

        # Strings used in custom formatter that are used in spec runner later to parse the output, these can be any arbitrary strings,
        # except comments below
        module Patterns
          P_TEST_START = "START"
          # for these three it is assmud in parser first char is test result
          P_TEST_PASSED = ".--"
          P_TEST_PENDING = "U--"
          P_TEST_FAILED = "F--"
          P_GROUP_NAME_START = "EX[["
          # group end shouldn't be something that may appear as class name in rspec
          P_GROUP_NAME_END = "]]"
          P_STATS = "STATS:"
        end

        include Patterns

        def initialize(output)
          super(output)
        end

        def example_started(example)
          @output.puts P_TEST_START
          @output.flush
        end

        def example_passed(example)
          @output.puts "#{P_TEST_PASSED}#{description example}"
          @output.flush
        end

        def example_pending(example)
          @output.puts "#{P_TEST_PENDING}#{description example}"
          @output.flush
        end

        def example_failed(example)
          @output.puts "#{P_TEST_FAILED}#{description example}"
          @output.flush
          @failed_examples << example
        end

        def description(example)
          example_group = example.example_group
          "#{P_GROUP_NAME_START}#{example_group.ancestors[-1].description}#{P_GROUP_NAME_END} #{example_group.ancestors.reverse[1..-1].map(&:description).join(' ')} #{example.description}"
        end

        def dump_summary(duration, example_count, failure_count, pending_count)
          @output.puts "#{P_STATS} #{duration}, #{example_count}, #{failure_count}, #{pending_count}"
          dump_failures
          @output.flush

        end

      end
    end
  end
end

if !defined? Moci::TestRunner # To avoid plugging it into moci when requiring to get patterns
  config = RSpec.configuration
  custom_formatter = RSpec::Core::Formatters::MociFormatter.new(STDOUT)
  config.instance_variable_set(:@reporter, RSpec::Core::Reporter.new(custom_formatter))
end
