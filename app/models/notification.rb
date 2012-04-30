# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * name [string]
# * notification_options [text] - serialized options specific to given handler
# * notification_type [string] - class name of the handler (Moci::Notificator::..)
# * updated_at [datetime] - last update time
class Notification < ActiveRecord::Base
  has_and_belongs_to_many :projects

  validates_presence_of :name
  validates_presence_of :notification_type #TODO validate

  serialize :notification_options, Hash

  include DynamicOptions::Model

  has_dynamic_options :definition => lambda { notificator.try(:class).try(:options_definition) || {} }

  def notificator
    @notificator ||= Moci::Notificator.const_get(notification_type).new(options) unless notification_type.blank?
  end

  def options
    # TODO merge on top of default notificatior options
    notification_options
  end

  def commit_built(commit)
    notificator.commit_built(commit)
  end

end
