class Ability
  include CanCan::Ability

  def initialize(user)

    #user ||= User.new
    #if user.admin?
      #can :view, :all
      #can :manage, :all
    #end

  end

end
