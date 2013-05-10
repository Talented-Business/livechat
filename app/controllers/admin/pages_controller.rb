class Admin::PagesController < ApplicationController
  before_filter :set_title
  before_filter :authenticate_operator!  
  before_filter :authorize_superadmin!

  layout 'admin'
	def general
    
  end
	def leaderboard
    
  end
	def online_ops
    
  end
	def message_history
    
  end
	def payment_for_ops
    
  end
	def notes_history
    
  end
private
  def set_title
    @title = case params[:id]
    when 'about'
      "About - Budget 24/7"
    when 'how_it_works'
      "How it works - Budget 24/7"
    when 'faq'
      "FAQ - Budget 24/7"
    when 'terms_of_use'
      "Terms of use - Budget 24/7"
    when 'help_create_account'
      "Help create account - Budget 24/7"
    when 'welcome'
      "Welcome - Budget 24/7"
    else
      "Budget 24/7"
    end
  end
  def authorize_superadmin!
    unless current_operator.has_role? :superadmin
      flash[:alert] = "You must be an admin to do that."
      redirect_to admin_schedules_path
    end
  end
  
end
