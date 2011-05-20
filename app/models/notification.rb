class Notification < ActiveRecord::Base
  has_and_belongs_to_many :projects

  validates_presence_of :name
  validates_presence_of :notification_type #TODO validate

  def notification_params
    YAML.load(self.notification_params_yaml.to_s)
  end

  def notification_params=(params)
    self.notification_params_yaml = params.to_yaml
  end

  def notificator
    Moci::Notificator.const_get(notification_type).new(self.notification_params)
  end

  def commit_built(commit)
    notificator.commit_built(commit)
  end
end
