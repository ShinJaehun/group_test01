# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    #can :manage, :all
    can :read, :all

    if user.present?
      if user.has_role?(:admin)
        can :manage, :all
      end

      can :manage, Post, user_id: user.id
      # 이것 때문인지 몰라도 로그인만 하면 아무데나 막글을 쓸 수 있다.
      can :update, User, id: user.id

      can :manage, Group, id: user.group_ids
      # 와 정상 동작한다!

      #can :manage, Project, group: { id: user.group_ids }
      #can :manage, Group, { :user_group => { :user_id => user.id } }
      #can :manage, Group, Group.joins(user_groups: :users).where(user_groups: {users: {id: user.id}})
      #실패
      #can :manage, User, User.joins(groups: :users).where(groups: {users: {id: user.id}})
      #이게 아직 테스트해보진 않았지만 user가 속해있는 그룹의 User를 관리하는 거 같애...
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
