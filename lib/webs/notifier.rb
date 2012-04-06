module Webs

  # Notifiers for different kind of events
  # Having everything in this place we can easily decide where we need to push given inforamtion.
  # So if we later want some live updates on page on user status change, we just push to additional
  # channel here and don't worry about changes anywhere else
  class Notifier
    attr_accessor :webs

    def initialize(webs)
      @webs = webs
    end

    def test_suite_run(tsr)
      webs.event [ch_global, ch_project(tsr.test_suite.project)], 'test_suite_run',
        :id => tsr.id,
        :state => tsr.state,
        :test_suite => {:id => tsr.test_suite.id, :name => tsr.test_suite.name}
    end

    def test_unit_run(tur)
      # IMPROVE make channel for test suite run
      webs.event [ch_global, ch_project(tur.test_suite_run.test_suite.project)], 'test_unit_run',
        :id => tur.id,
        :result => tur.result,
        :test_unit => {:id => tur.test_unit.id, :name => tur.test_unit.name, :class_name => tur.test_unit.class_name},
        :test_suite_run => {:id => tur.test_suite_run.id}
    end

    protected

    def ch_global
      'moci'
    end

    def ch_project(project)
      "moci_project_#{project.id}"
    end

  end

end

