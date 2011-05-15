class TestSuiteRunsController < ApplicationController

  def index
    #TODO: paginate
    @test_suite_runs = TestSuiteRun.order('created_at DESC').all
  end
end
