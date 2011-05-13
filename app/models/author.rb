class Author < ActiveRecord::Base

  has_many :commits

  include Gravtastic
  gravtastic
end
