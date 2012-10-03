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
    # begin
      Pusher[channel].trigger(event, data)
      true
    # rescue Exception => e
    #   false
    # end
  end

  def self.notify(event, *params)
    notifier.send event, *params
  end


  protected

  def self.notifier
    @notifier ||= Webs::Notifier.new self
  end

end
