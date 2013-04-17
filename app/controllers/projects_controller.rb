class ProjectsController < ApplicationController
  before_filter :must_be_in_project, only: [:show, :stats, :tr_last_run]

  def show
  end

  def choose
  end

  def stats
    @assertions = []
    @tests_failing = []
    @run_times = []
    @project.test_suites.each do |ts|
      # IMPROVE: N+!, but it's stats, we can cache
      data = @project.commits.order('committed_at DESC').limit(500).map do |commit|
        r = TestSuiteRun.select('max(assertions_count) assertions_count, min(errors_count) errors_count ,min(failures_count) failures_count, avg(run_time) run_time').where(:commit_id => commit.id, :test_suite_id => ts.id).first
        r['assertions_count'] = nil if r['assertions_count'] == 0
        r['total_errors'] = r['errors_count'].to_i + r['failures_count'].to_i
        r['run_time'] = nil if r['run_time'] == 0
        r
      end

      @assertions << {:label => ts.name, :data => flot_data(data,'assertions_count')}
      @tests_failing << {:label => ts.name, :data => flot_data(data,'total_errors')}
      @run_times << {:label => ts.name, :data => flot_data(data,'run_time')}
    end
  end

  def tr_last_run
    tsr = @project.test_suite_runs.find(params[:test_suite_run_id])
    render tsr
  end

  protected

  def flot_data(data, value)
    data_with_index = []
    data.compact.reverse.each_with_index { |d,i| data_with_index << [i,d[value]] }
    data_with_index
  end
end
