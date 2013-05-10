class Ability
  include CanCan::Ability

  def initialize(operator)
    
    permission = operator.get_permission
    if operator.has_role? :admin
      if permission.editable_profile_admin
        can :edit, Operator
      end
      if permission.character_profile_admin
        can :profile, Operator
      end
      if permission.mass_sending_admin
        
      end
      if permission.kickop_admin
        
      end
      if permission.editable_note_admin
        can :manage, Note
      end
    else
      if permission.notes
        can :read, Note        
      end
      if permission.outside_shift
        can :work_page, Schedule 
      end
      if permission.schedule
        
      end
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
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
