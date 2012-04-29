module Moci
  module TestRunner
    def self.types
      (constants.map(&:to_s) - ['Base']).sort
    end
  end
end
