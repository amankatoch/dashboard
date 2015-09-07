class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :create, User
    can :create, BetaRequest
    if user.persisted?
      can :read, User
      can :update, User, id: user.id
      can :locations, User, id: user.id

      can :manage, DeviceToken, user_id: user.id
      can :manage, UserFavorite, user_id: user.id
      can :manage, SessionRequest, requester_id: user.id
      can :manage, Notification, user_id: user.id
      can :read, Skill
    end
  end
end
