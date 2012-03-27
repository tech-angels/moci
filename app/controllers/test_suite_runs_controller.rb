class TestSuiteRunsController < ApplicationController

  def index
    #TODO: paginate
    @test_suite_runs = TestSuiteRun.order('created_at DESC').all
  end

  def show
    @test_suite_run = TestSuiteRun.find params[:id]
    @project = @test_suite_run.test_suite.project
    @test_unit_runs = @test_suite_run.test_unit_runs.includes(:test_unit).all
  end

  def blame
    @test_suite_run = TestSuiteRun.find params[:id]
    @test_unit = TestUnit.find params[:test_unit_id]
    @commit=  @test_suite_run.blame(@test_unit)
    render :partial => 'blame'
  end
end
