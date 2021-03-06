require 'rspec'
require 'rspec/core/formatters/base_text_formatter'
require 'json'

module RSpec
  module Core
    module Formatters
      class MociFormatter < BaseTextFormatter


        def initialize(output)
          super(output)
        end

        def example_started(example)
          moci_push event: "start"
        end

        def example_passed(example)
          moci_push(format_result(example, '.'))
        end

        def example_pending(example)
          moci_push(format_result(example, 'P'))
        end

        def example_failed(example)
          moci_push(format_result(example, 'F'))
          @failed_examples << example
        end

        def description(example)
          example_group = example.example_group
          ancestors = example_group.ancestors.select{ |ancestor| ancestor.respond_to?(:description) and !ancestor.eql?(RSpec::Core::ExampleGroup) }

          {
            :group => ancestors[-1].description.strip,
            :name => "#{ancestors.reverse[1..-1].map(&:description).join(' ')} #{example.description}".strip
          }
        end

        def dump_summary(duration, example_count, failure_count, pending_count)
          moci_push :event => "stats",
            :duration => duration,
            :example_count => example_count,
            :failure_count => failure_count,
            :pending_count => pending_count
          dump_failures

        end

        protected

        def moci_push(data)
          @output.puts "MOCI[[#{data.to_json}]]"
          @output.flush
        end

        def format_result(example, result)
          {event: "result", result: result, example: description(example), duration: example.execution_result[:run_time]}
        end

      end
    end
  end
end

config = RSpec.configuration
custom_formatter = RSpec::Core::Formatters::MociFormatter.new(STDOUT)
config.instance_variable_set(:@reporter, RSpec::Core::Reporter.new(custom_formatter))
