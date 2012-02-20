# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * email [string]
# * name [string]
# * updated_at [datetime] - last update time
class Author < ActiveRecord::Base

  has_many :commits

  validates_presence_of :email
  validates_uniqueness_of :email

  include Gravtastic
  gravtastic
end
