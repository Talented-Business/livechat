class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_sessions_for_op
  def current_ability
    current_operator.ability
  end
  protected
  def check_sessions
    Session.check_sessions 
  end
  def check_sessions_for_op
    current_operator.check_sessions if current_operator
  end
end
