module Moci
  module Notificator
    class Campfire < Base

      define_options do
        {
          :room_url => {
            :description => "e.g. https://your-awesome-company.campfirenew.com",
            :required => true
          },
          :auth_token => {
            :required => true
          },
          :room_id => {
            :required => true
          },
          :style => {
            :type => :select,
            :options => ['verbose','compact'],
            :default => "verbose",
            :description => "verbose: full list of fixed/introduced errors, compact: just build status and link to moci commit page"
          }
        }
      end


      include HTTParty
      headers    'Content-Type' => 'application/json'

      def initialize(params)
        # TODO XXX this obviously is sick this way, we want
        # httparty and all alse at object not class level here
        self.class.base_uri   params[:room_url]
        self.class.basic_auth params[:auth_token],'x'
        #self.class.headers    'Content-Type' => 'application/json'
        @room_id = params[:room_id]
        @params = params
        super
      end

      def commit_built(commit)
        x = "#{commit.project.name} #{commit.number[0..4]} #{commit.description[0..20]}.. @#{commit.author.name} on #{commit.project.vcs_branch_name}: #{commit.build_state.upcase}"
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
            x += "\n  #{tsr.test_suite.name}: #{tsr.build_state}#{m}" unless m.empty?
          end
        else
          x += " ( #{Moci.config[:application_url]}c/#{commit.id} )"
        end
        pp msg x
        sound 'trombone' if commit.build_state == 'fail'
        sound 'rimshot' if commit.build_state == 'clean' && fixed > 0
        true
      end

      def msg(str)
        room.message str
      end

      def sound(name)
        room.play_sound(name)
      end

      def room
        room = Room.new(@room_id)
        pp room
        room
      end

      def default_options
        {:style => 'compact'}
      end

      protected

      # Campfire example API stuff

      def self.rooms
        Campfire.get('/rooms.json')["rooms"]
      end

      def self.room(room_id)
        Room.new(room_id)
      end

      def self.user(id)
        Campfire.get("/users/#{id}.json")["user"]
      end

      def self.foo(bar)
        room = Campfire.room(362727)
        pp room
        room.message bar
      end


      class Room
        attr_reader :room_id

        def initialize(room_id)
          @room_id = room_id
        end

        def join
          post 'join'
        end

        def leave
          post 'leave'
        end

        def lock
          post 'lock'
        end

        def unlock
          post 'unlock'
        end

        def message(message)
          send_message message
        end

        def paste(paste)
          send_message paste, 'PasteMessage'
        end

        def play_sound(sound)
          send_message sound, 'SoundMessage'
        end

        def transcript
          get('transcript')['messages']
        end

        private

        def send_message(message, type = 'Textmessage')
          post 'speak', :body => {:message => {:body => message, :type => type}}.to_json
        end

        def get(action, options = {})
          Campfire.get room_url_for(action), options
        end

        def post(action, options = {})
          Campfire.post room_url_for(action), options
        end

        def room_url_for(action)
          "/room/#{room_id}/#{action}.json"
        end
      end



    end
  end
end
