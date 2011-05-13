class Commit < ActiveRecord::Base
  belongs_to :author
  belongs_to :project

  has_many :test_suite_runs

  #TODO? maybe: commiter? multiple parents?
end
