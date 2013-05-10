class Admin::PermissionsController < ApplicationController
  before_filter :authenticate_operator!  
  before_filter :authorize_admin!
  before_filter :find_operator, :only => [:create,
                                         :update]  
  def index
    
  end
  def create
    @permission = Permission.new(params[:permission])
    @permission.operator = @operator
    unless @operator.has_role? :admin
      @permission.start_date = Date.strptime(params[:permission][:start_date], '%m/%d/%Y')
      @permission.end_date = Date.strptime(params[:permission][:end_date], '%m/%d/%Y')
    end
    if @permission.save
      message = "Permission has been saved."
    else
      message = "Permission has not been saved."
    end    
    render "create"
    #render :js=>"alert('#{message}')"
  end
  def update
    begin
      permission = Permission.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render :js=>"alert('The permission you were looking for could not be found.')" and return
    end                  
    unless @operator.has_role? :admin
      permission.start_date = Date.strptime(params[:permission][:start_date], '%m/%d/%Y')
      permission.end_date = Date.strptime(params[:permission][:end_date], '%m/%d/%Y')
      permission.idle_time = params[:permission][:idle_time]
      permission.notes = params[:permission][:notes]
      permission.outside_shift = params[:permission][:outside_shift]
      permission.schedule = params[:permission][:schedule]
    else
      permission.update_attributes(params[:permission])
    end
    if permission.save
      message = "Permission has been saved."
    else
      message = "Permission has not been saved."
    end    
    render :js=>"alert('#{message}')"
    #render :js=>"alert('#{permission.end_date}')"
  end
  private
    def find_operator
      @operator = Operator.find(params[:permission][:operator_id])
      rescue ActiveRecord::RecordNotFound
      render :js=>"alert('The operator you were looking for could not be found.')"
    end
    def authorize_admin!
      unless current_operator.has_role? :admin or current_operator.has_role? :superadmin
        flash[:alert] = "You must be an admin to do that."
        redirect_to admin_schedules_path
      end
    end
  
end
