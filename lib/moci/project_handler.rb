module Moci
  module ProjectHandler
    def self.types
      constants.map(&:to_s)
    end
  end
end
