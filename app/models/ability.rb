class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    can :view, Project do |project|
      user.project_permissions.where(:project_id => project, :name => 'view').any?
    end
    if user.admin?
      can :view, :all
      can :manage, :all
    end
  end

end
