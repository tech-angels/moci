module Moci
  module Notificator
    def self.types
      constants.map(&:to_s) - ['Base']
    end
  end
end
