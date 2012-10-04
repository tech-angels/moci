require 'tinder'

module Moci
  module Notificator
    class Campfire < Base
      include ActionView::Helpers::TextHelper

      define_options do
        o :subdomain,  "e.g. https://[subdomain].campfirenow.com", :required => true
        o :auth_token, :required => true
        o :room_name,  :required => true
        o :style,      "verbose: full list of fixed/introduced errors, compact: just build status and link to moci commit page",
                       :type => :select, :options => ['verbose','compact'], :default => "verbose"
      end

      def initialize(params)
        unless params.empty?
          @campfire = Tinder::Campfire.new params[:subdomain], :token => params[:auth_token] unless params[:subdomain].blank?
          @room = @campfire.find_room_by_name(params[:room_name])
          @params = params
        end
        super
      end

      def commit_built(commit)
        message = "[#{commit.project.name}] #{commit.number[0..4]} #{truncate(commit.description, lenght: 40)} @#{commit.author.name} on #{commit.project.vcs_branch_name}: #{commit.build_state.upcase}"
        fixed = 0
        if @options[:style] == 'verbose'
          commit.latest_test_suite_runs.each do |tsr|
            m = ""
            tsr.gone_errors.each do |error|
              m += "\n    * FIXED [#{error.class_name}] - #{error.name}"
              fixed += 1
            end
            tsr.errors.each do |error|
              m += "\n    * #{tsr.new_errors.include?(error) ? 'INTRODUCED' : 'ERR'} [#{error.class_name}] - #{error.name}"
            end
            message += "\n  #{tsr.test_suite.name}: #{tsr.build_state}#{m}" unless m.empty?
          end
        else
          message += " ( #{Moci.config[:application_url].match(/.+[^\/]/)[0]}/c/#{commit.id} )"
        end
        @room.speak message
        @room.play 'trombone' if commit.build_state == 'fail'
        @room.play 'rimshot' if commit.build_state == 'clean' && fixed > 0
        true
      end

      def default_options
        {:style => 'compact'}
      end
    end
  end
end
