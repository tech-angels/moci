class TestSuiteRunsController < ApplicationController

  def index
    #TODO: paginate
    must_be_in_project if params[:project_id]
    @test_suite_runs = TestSuiteRun.order('test_suite_runs.created_at DESC').includes(commit: :author).includes(test_suite: :project).where('projects.id' => @project.try(:id) || visible_projects.map(&:id)).page(params[:page]).per(20)
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
    render partial: 'blame'
  end
end
