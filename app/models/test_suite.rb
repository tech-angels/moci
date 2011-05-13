class TestSuite < ActiveRecord::Base
  belongs_to :project

  #TODO: suite types

  def run
    #TODO: decide which runner based on type
  end
end
