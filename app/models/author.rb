class Author < ActiveRecord::Base

  has_many :commits

  validates_presence_of :email
  validates_uniqueness_of :email

  include Gravtastic
  gravtastic
end
