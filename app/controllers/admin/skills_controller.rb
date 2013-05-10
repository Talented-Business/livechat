class Admin::SkillsController < ApplicationController
  layout "admin"
  before_filter :authenticate_operator!  
  before_filter :authorize_admin!
  before_filter :find_skill, :only => [:delete,
                                         :edit,
                                         :update,
                                         :destroy]  
  def index
    @skills = Skill.all
  end
  def show
  end
  def new
    @skill = Skill.new
  end
  def create
    @skill = Skill.new(params[:skill])
    if @skill.save
      flash[:notice] = "Skill has been created."
      redirect_to admin_skills_path
    else
      flash[:alert] = "Skill has not been created."
      render "new"
    end    
  end
  def update
    if @skill.update_attributes(params[:skill])
      flash[:notice] = "Skill has been updated."
      redirect_to admin_skills_path
    else
      flash[:alert] = "Skill has not been updated."
      render :action => "edit"
    end
  end
  def destroy
    @skill.destroy
    flash[:notice] = "Skill has been deleted."
    redirect_to admin_skills_path    
  end
  def delete
    @skill.destroy
    flash[:notice] = "Skill has been deleted."
    redirect_to admin_skills_path
  end
  private
    def find_skill
      @skill = Skill.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The skill you were looking" +
                      " for could not be found."
      redirect_to admin_skills_path
    end
    def authorize_admin!
      unless current_operator.has_role? :admin or current_operator.has_role? :superadmin
        flash[:alert] = "You must be an admin to do that."
        redirect_to admin_schedules_path
      end
    end
end
