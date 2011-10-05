require 'rspec/core/formatters/base_text_formatter'

module RSpec
  module Core
    module Formatters
      class MociFormatter < BaseTextFormatter

        def initialize(output)
          super(output)
        end

        def example_started(example)
          @output.puts "START"
          @output.flush
        end

        def example_passed(example)
          @output.puts ".--#{description example}"
          @output.flush
        end

        def example_pending(example)
          @output.puts "U--#{description example}"
          @output.flush
        end

        def example_failed(example)
          @output.puts "F--#{description example}"
          @output.flush
        end

        def description(example)
          example_group = example.example_group
          "EX[[#{example_group.ancestors[-1].description}]] #{example_group.ancestors.reverse[1..-1].map(&:description).join(' ')} #{example.description}"
        end

        def dump_summary(duration, example_count, failure_count, pending_count)
          @output.puts "STATS: #{duration}, #{example_count}, #{failure_count}, #{pending_count}"
          @output.flush
        end

      end
    end
  end
end

config = RSpec.configuration
custom_formatter = RSpec::Core::Formatters::MociFormatter.new(STDOUT)
config.instance_variable_set(:@reporter, RSpec::Core::Reporter.new(custom_formatter))
