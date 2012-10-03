Pusher.logger = Rails.logger
Pusher.encrypted  = Moci.config[:pusher][:encrypted] == "true" ? true : false
Pusher.host       = Moci.config[:pusher][:host]
Pusher.port       = Moci.config[:pusher][:port]
Pusher.app_id     = Moci.config[:pusher][:app_id]
Pusher.key        = Moci.config[:pusher][:key]
Pusher.secret     = Moci.config[:pusher][:secret]
