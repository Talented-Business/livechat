class Admin::RemindersController < ApplicationController
  layout "admin"
  before_filter :authenticate_operator!  
  before_filter :authorize_admin!
  def new
    @reminder = Reminder.new
    @possible_days = Reminder.possible_days
    render "new"
  end
  def edit
    @reminder = Reminder.find(params[:id])
    @possible_days = Reminder.possible_days
    @possible_days.push @reminder.inactivity
    render "edit"
  end
  def create
    reminder = Reminder.new(params[:reminder])
    if reminder.name.nil? || reminder.name == ""
      reminder.name = "Reminder for "+reminder.inactivity.to_s + " days"
    end
    if reminder.save
      @reminders = Reminder.all
      render "update"
    else
      render :js=>"alert('The reminder has not been creating.')"
    end
  end
  def update
    reminder = Reminder.find(params[:id])
    if params[:reminder][:name].nil? || params[:reminder][:name] == ""
      params[:reminder][:name] = "Reminder for "+params[:reminder][:inactivity].to_s + " days"
    end
    if reminder.update_attributes(params[:reminder])
      @reminders = Reminder.all
      render "update"
    else
      render :js=>"alert('The reminder has not been updating.')"
    end
  end
  def destroy
    reminder = Reminder.find(params[:id])
    reminder.destroy
    @reminders = Reminder.all
    @possible_days = Reminder.possible_days
    render "update"
  end
  private
    def authorize_admin!
      unless current_operator.has_role? :admin or current_operator.has_role? :superadmin
        flash[:alert] = "You must be an admin to do that."
        redirect_to admin_schedules_path
      end
    end  
end
