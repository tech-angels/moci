# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime] - creation time
# * name [string] - currently possibe values are [:name, :manage]
# * project_id [integer] - belongs_to Project
# * user_id [integer] - belongs_to User
class ProjectPermission < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
end
