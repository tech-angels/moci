class Commit < ActiveRecord::Base
  belongs_to :author
  belongs_to :project

  #TODO? maybe: commiter? multiple parents?
end
