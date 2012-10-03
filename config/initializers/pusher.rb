Pusher.logger = Rails.logger
if Moci.config[:pusher]
  Pusher.encrypted  = Moci.config[:pusher][:encrypted] == "true" ? true : false if Moci.config[:pusher][:encrypted]
  Pusher.host       = Moci.config[:pusher][:host] if Moci.config[:pusher][:host]
  Pusher.port       = Moci.config[:pusher][:port] if Moci.config[:pusher][:port]
  Pusher.app_id     = Moci.config[:pusher][:app_id]
  Pusher.key        = Moci.config[:pusher][:key]
  Pusher.secret     = Moci.config[:pusher][:secret]
end
