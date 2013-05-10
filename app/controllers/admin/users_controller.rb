class Admin::UsersController < ApplicationController
  layout "admin"
  before_filter :authenticate_operator!  
  before_filter :authorize_admin!
  before_filter :find_user, :only => [:delete,
                                         :edit,
                                         :update,
                                         :unblock,
                                         :block,
                                         :destroy]  

  def index
    @users = User.all
  end
  def show
  end
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = "User has been updated."
      redirect_to admin_users_path
    else
      flash[:alert] = "User has not been updated."
      render :action => "edit"
    end
  end
  def destroy
    @user.destroy
    flash[:notice] = "User has been deleted."
    redirect_to admin_users_path    
  end
  def delete
    @user.destroy
    flash[:notice] = "User has been deleted."
    redirect_to admin_users_path
  end
  def block
    @user.update_attribute(:block, true)
    flash[:notice] = "User has been blocked."
    redirect_to admin_users_path
  end
  def unblock
    @user.update_attribute(:block, false)
    flash[:notice] = "User has been blocked."
    redirect_to admin_users_path
  end
  private
    def find_user
      @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The user you were looking" +
                      " for could not be found."
      redirect_to admin_users_path
    end
    def authorize_admin!
      unless current_operator.has_role? :admin or current_operator.has_role? :superadmin
        flash[:alert] = "You must be an admin to do that."
        redirect_to admin_schedules_path
      end
    end
end
