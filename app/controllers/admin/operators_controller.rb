class Admin::OperatorsController < ApplicationController
  layout "admin"
  before_filter :authenticate_operator!  
  before_filter :authorize_admin!
  before_filter :find_operator, :only => [:delete,
                                         :edit,
                                         :update,
                                         :unblock,
                                         :block,
                                         :profile,
                                         :permission,
                                         :session_history,
                                         :attendance_history,
                                         :destroy]  
  before_filter :check_sessions, :only =>[:session_history]
  def index
    @operators = Operator.all
  end
  def show
  end
  def new
    @operator = Operator.new
  end
  def edit
     authorize! :edit, @operator
  end
  def create
    @operator = Operator.new(params[:operator])
    if @operator.save
      flash[:notice] = "Operator has been created."
      redirect_to admin_operators_path
    else
      flash[:alert] = "Operator has not been created."
      render "new"
    end    
  end
  def update
    if params.has_key?("languages")
      params[:operator][:languages] = params[:languages]
    end
    if params[:operator][:password].present?
      result = @operator.update_with_password(params[:operator])
    else
      result = @operator.update_without_password(params[:operator])
    end
    if result
      if params.has_key?("skills")
        skills = []
        params[:skills].each do | skill |
          s = Skill.find_by_name(skill)
          skills << s
        end
        @operator.skills = skills
        @operator.save
      end
      flash[:notice] = "Operator has been updated."
      redirect_to admin_operators_path
    else
      flash[:alert] = "Operator has not been updated."+@operator.errors.messages
      render :action => params[:template_action]
    end
  end
  def destroy
    @operator.destroy
    flash[:notice] = "Operator has been deleted."
    redirect_to admin_operators_path    
  end
  def delete
    @operator.destroy
    flash[:notice] = "Operator has been deleted."
    redirect_to admin_operators_path
  end
  def block
    @operator.update_attribute(:block, true)
    flash[:notice] = "Operator has been blocked."
    redirect_to admin_operators_path
  end
  def unblock
    @operator.update_attribute(:block, false)
    flash[:notice] = "Operator has been unblocked."
    redirect_to admin_operators_path
  end
  def profile
    @skills = Skill.all
    authorize! :profile, @operator
  end
  def session_history
    @chat_users = User.where(:block=>false)
    if params.has_key?(:start_date)
      start_date = Date.strptime(params[:start_date], '%m/%d/%Y')
      @start_date = params[:start_date]
    else
      start_date = Date.today-1
      @start_date = start_date.strftime("%m/%d/%Y")
    end
    if params.has_key?(:end_date) && params[:end_date]!=""
      end_date = Date.strptime(params[:end_date], '%m/%d/%Y')
      if start_date < end_date
        @end_date = params[:end_date]
      else
        end_date = Date.today + 1
        @end_date = nil
      end
    else
      end_date = Date.today + 1
      @end_date = nil
    end    
    if params.has_key?(:chat_user)
      @chat_user_id = params[:chat_user] if params.has_key?(:chat_user)
      @sessions = current_operator.sessions.where("start > ? and start < ? and user_id=?",start_date, end_date,@chat_user_id)
    else
      @chat_user_id = nil
      @sessions = current_operator.sessions.where("start > ? and start < ? ",start_date, end_date)
    end
  end
  def attendance_history
    @thedate = Date.today
    @thedate = params[:date].to_date if params[:date]
    begindate = @thedate.beginning_of_week
    @op_schedules = []
    (0..6).each do |w|
      @op_schedules[w] = []
      (0..23).each do |num|
        @op_schedules[w][num] = Schedule.where(:thedate=>begindate+w, :number=>num, :operator_id=>@operator.id).first_or_initialize
      end  
    end        
  end
  def message_history
    @s = Session.find(params[:key])
    if @s.check_status
      chat_messages = []
      @s.chat_messages.each do |chat|
        chat_message = Hash.new
        chat_message['message'] = chat.message
        if chat.direction
          chat_message['to'] = chat.user.name      
          chat_message['sender'] = chat.operator.name
        else
          chat_message['sender'] = chat.user.name      
          chat_message['to'] = chat.operator.name
        end
        chat_message['created_at'] = chat.created_at
        chat_messages.push  chat_message
      end
    else
      chat_messages = []
      @s.chat_history.each do |chat|
        chat_message = Hash.new
        chat_message['message'] = chat[:message]
        if chat['direction']
          chat_message['to'] = chat[:user]      
          chat_message['sender'] = chat[:operator]
        else
          chat_message['sender'] = chat[:user]     
          chat_message['to'] = chat[:operator]
        end
        chat_message['created_at'] = chat[:created_at]
        chat_messages.push  chat_message      
      end
    end
    render :json=>{:messages=>chat_messages }
  end
  def permission
    @operator = Operator.find(params[:id])
    @permission = @operator.get_permission
    respond_to do |format|
      format.js 
    end
  end
  private
    def find_operator
      @operator = Operator.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The operator you were looking" +
                      " for could not be found."
      redirect_to admin_operators_path
    end
    def authorize_admin!
      unless current_operator.has_role? :admin or current_operator.has_role? :superadmin
        flash[:alert] = "You must be an admin to do that."
        redirect_to admin_schedules_path
      end
    end
end
