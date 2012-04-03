class ProjectsController < ApplicationController
  def show
    must_be_in_project
  end

  def choose
  end

  def stats
    must_be_in_project
    @assertions = {}
    @project.test_suites.each do |ts|
      # IMPROVE: N+!, but it's stats, we can cache
      data = @project.commits.order('committed_at DESC').limit(500).map do |commit|
        number = TestSuiteRun.where(:commit_id => commit.id, :test_suite_id => ts.id).average(:assertions_count).to_i
        number == 0 ? nil : number
      end
      data_with_index = []
      data.compact.reverse.each_with_index { |d,i| data_with_index << [i,d] }
      @assertions[ts.name] = {:label => ts.name, :data => data_with_index}
    end
  end
end
