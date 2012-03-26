# Attributes:
# * id [integer, primary, not null] - primary key
# * author_id [integer] - belongs_to Author
# * committed_at [datetime] - when commit was created in repo
# * created_at [datetime] - creation time (in our database)
# * description [text] - description provided inside commit
# * dev_structure [text] - keeps database structure FIXME: reorganize, make it some data_yaml or whatever
# * number [string] - commit number as in VCS (e.g. sha hash in git)
# * parent_id [integer] - belongs_to parent Commit
# * preparation_log [text] - FIXME: remove me, it's present in ProjectInstanceCommit
# * project_id [integer] - belongs_to Project
# * skipped [boolean] - commit can be marked as skipped if we don't want moci to run it
# * updated_at [datetime] - last update time
class Commit < ActiveRecord::Base
  #TODO? maybe: commiter? multiple parents?
  #
  belongs_to :author
  belongs_to :project

  has_many :test_suite_runs
  has_many :project_instance_commits

  has_and_belongs_to_many :parents,
    :class_name => 'Commit', :association_foreign_key => 'parent_id', :join_table => 'commits_parents'

  def short_description
    desc = description.split("\n").first
    if desc.size > 100
      desc = desc[0..97] + '...'
    end
    desc
  end

  def short_number
    number[0..8]
  end

  def next
    #FIXME TODO XXX
    project.commits.order('committed_at ASC').where('committed_at > ?',self.committed_at).first
  end

  def run_test_suites
    checkout
    prepare
    project.run_test_suites(true)
  end

  def build_state
    # OPTIMIZE like hell
    new_errors = latest_test_suite_runs.compact.map(&:new_errors).map(&:size).sum
    errors = latest_test_suite_runs.compact.map(&:errors).map(&:size).sum
    exitstatuses = latest_test_suite_runs.compact.map(&:exitstatus)
    return 'running'  if first_test_suite_runs.compact.any?(&:running?)
    return 'preparation_failed' if project_instance_commits.any? {|c| c.state == 'preparation_failed'} # FIXME
    return 'pending'  if latest_test_suite_runs.any? {|x| x.nil?}
    return 'fail' if new_errors > 0
    return 'ok' if new_errors == 0 && errors > 0
    # TODO name this tate differently probably, failed_to_run maybe?
    # It's the case when test suite returned non-zero exitcode, but we had no test_unit_run errors
    return 'fail' unless exitstatuses.all?
    return 'clean' if errors == 0
  end

  def notify_test_suite_done(tsr)
    if build_state != 'pending'
      project.notifications.each do |notif|
        notif.commit_built(self)
      end
    end
  end

  def latest_test_suite_runs
    # OPTIMIZE
    @latest_test_suite_runs ||= project.test_suites.map do |ts|
      test_suite_runs.where(:test_suite_id => ts.id).order('created_at DESC').first
    end
  end

  def first_test_suite_runs
    # OPTIMIZE
    @first_test_suite_runs ||= project.test_suites.map do |ts|
      test_suite_runs.where(:test_suite_id => ts.id).order('created_at ASC').first
    end
  end

  # returns ProjectInstanceCommit for given instance if exists
  # TODO: I really don't like that method name
  def in_instance(project_instance)
    project_instance.commits.find_by_commit_id(self.id)
  end

  def prepared?
    ProjectInstanceCommit.where(:commit_id => self.id).any? &:prepared?
  end

  # IMPROVE this doesn't really fit in here think about some abstraction for this
  def repo_url
    if project.options[:github]
      "https://github.com/#{project.options[:github]}/commit/#{self.number}"
    end
  end

end
