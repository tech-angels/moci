module DynamicOptions
  module Model

    module ClassMethods
      def has_dynamic_options(opts)
        @dynamic_options = opts
      end

      def dynamic_options
        @dynamic_options
      end
    end

    def dynamic_options_defaults
      defaults = {}.with_indifferent_access
      dynamic_options_definition.each_pair do |key,opts|
        defaults[key] = opts[:default] if opts[:default]
      end
      defaults
    end

    def dynamic_options
      dynamic_options_defaults.merge(options)
    end

    def dynamic_options=(new_options)
      # TODO validate if keys are valid
      self.options = (options || {}).merge(new_options)
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def dynamic_options_definition
      definition = self.class.dynamic_options[:definition]
      definition.kind_of?(Proc) ? definition.bind(self).call : definition
    end
  end

  module Definition
    # TODO consider addirng some DSL instead of just providing hash
    def define_options(&block)
      @options_definition = options_definition.merge(block.call)
    end

    def options_definition
      @options_definition || {}
    end
  end


  module Formtastic
    module Helper
      def dynamic_options
        f = self

        f.inputs "Options", :for => :dynamic_options, :class => "inputs options", "data-object-id" => f.object.id do |o|
          html = "" # this seems so weird to do to make formtastic works
          f.object.dynamic_options_definition.each_pair do |name, options|

            value = f.object.dynamic_options[name]

            field_options = {
              :input_html => { :value => value },
              :label => options[:name] || name.to_s.humanize,
              :hint => options[:description]
            }

            case options[:type]
            when :boolean
              field_options.merge!(:as => :select,
                :column_type => :boolean,
                :selected => value,
                :include_blank => false)
            when :select
              field_options.merge!(:as => :select,
                :collection => options[:options],
                :column_type => :text,
                :selected => value,
                :include_blank => false)
            end

            html = o.input name, field_options
          end
          html
        end
      end
    end
  end

  module View

    def display_options(object)
      html = "<ul>"
      object.dynamic_options_definition.each_pair do |name, opts|
        html << "<li>#{opts[:name] || name.to_s.humanize}: <strong>#{object.dynamic_options[name]}</strong></li>"
      end
      html << "</ul>"
    end

  end
end

module Formtastic
  class FormBuilder < ActionView::Helpers::FormBuilder
    include DynamicOptions::Formtastic::Helper
  end
end
