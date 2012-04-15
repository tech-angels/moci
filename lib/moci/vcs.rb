module Moci
  module VCS
    def self.types
      constants.map(&:to_s)
    end
  end
end
