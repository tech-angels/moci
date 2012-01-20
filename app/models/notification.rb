class Notification < ActiveRecord::Base
  has_and_belongs_to_many :projects

  validates_presence_of :name
  validates_presence_of :notification_type #TODO validate

  serialize :notification_options, Hash

  def notificator
    Moci::Notificator.const_get(notification_type).new(options)
  end

  def options
    # TODO merge on top of default notificatior options
    notification_options
  end

  def commit_built(commit)
    notificator.commit_built(commit)
  end

end
