require 'timeout'

# Abstraction layer around whatever is used to push live notification to the website.
# Currently Pusher is used.
# * it enables us to easily change pusher to something else
# * it works as notifications router, so that all channels and data to push are decided here not in models
module Webs

  def self.push(channel, data={})
    event = data.delete :event
    self.event(channel, event, data)
  end

  def self.event(channel, event, data={})
    return channel.map { |ch| self.event(ch, event, data) }.all? if channel.kind_of? Array
    begin
      Timeout::timeout(3) do
        Pusher[channel].trigger(event, data)
      end
    rescue Timeout::Error
      # if it didn't make it within 3 seconds, that's too bad.
      return false
    end
    return true
  end

  def self.notify(event, *params)
    notifier.send event, *params
  end


  protected

  def self.notifier
    @notifier ||= Webs::Notifier.new self
  end

end
