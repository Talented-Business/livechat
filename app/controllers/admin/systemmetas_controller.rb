class Admin::SystemmetasController < ApplicationController
  include ApplicationHelper
  layout "admin"
  before_filter :authenticate_operator!  
  before_filter :authorize_admin!
  def index
    @settings = Systemmeta.all
  end
  def show
  end
  def new
    @systemmeta = Systemmeta.new
  end
  def create
    @settings = params[:settings]
    @settings.each do | key, value |
      setting = Systemmeta.find_or_initialize_by_meta_key(key)
      setting.update_attributes(
        :meta_key => key,
        :meta_value => value
      )
    end
    render "index"
  end
  def permission
    @operators  = Operator.operators
    @admins     = Operator.admins
    @settings = Systemmeta.all
    @operator = @operators.first
    @permission = @operator.get_permission
    render "permission"
  end
  def market
    @reminders = Reminder.all
    @settings = Hash.new
    @settings['operator_daily_message'] = Systemmeta.get_setting("operator_daily_message")
    @settings['user_daily_message'] = Systemmeta.get_setting("user_daily_message")
    render "market"
  end
  def marketing
    @settings = params[:settings]
    operator_daily_message = @settings['operator_daily_message']
    user_daily_message = @settings['user_daily_message']
    update = false
    unless operator_daily_message ==  Systemmeta.get_setting("operator_daily_message")
      setting = Systemmeta.find_or_initialize_by_meta_key("_operator_daily_message")
      setting.update_attributes(
        :meta_key => "_operator_daily_message",
        :meta_value => Systemmeta.get_setting("operator_daily_message")
      )
      setting = Systemmeta.find_or_initialize_by_meta_key("operator_daily_message")
      setting.update_attributes(
        :meta_key => "operator_daily_message",
        :meta_value => operator_daily_message
      )
      update = true
      operators = Operator.where(:block=>false)
      operators.each do |operator|
        next if operator == current_operator
        topic = Topic.where("subject = 'Daily Message' and recipient_id = ? and sender_id = ?",operator.id, current_operator.id ).first
        if topic.nil?
          topic = Topic.new
          topic.subject = "Daily Message"
          topic.recipient = operator
          topic.sender = current_operator
          topic.save
        end
        msg = Message.new()
        msg.recipient = operator
        msg.sender = current_operator
        msg.topic = topic
        msg.message = operator_daily_message
        saved = msg.save      
      end  
    end
    unless user_daily_message ==  Systemmeta.get_setting("user_daily_message")
      setting = Systemmeta.find_or_initialize_by_meta_key("_user_daily_message")
      setting.update_attributes(
        :meta_key => "_user_daily_message",
        :meta_value => Systemmeta.get_setting("user_daily_message")
      )
      setting = Systemmeta.find_or_initialize_by_meta_key("user_daily_message")
      setting.update_attributes(
        :meta_key => "user_daily_message",
        :meta_value => user_daily_message
      )
      update = true
      users = User.where(:daily_message=>false)
      User.daily_messages(user_daily_message)
    end
    if update 
      render :js=>"alert('Successfully updated')"
    else
      render :js=>""
    end
  end
  def updates
    checked_settings = ['outsite_shift_op','notes_op','order_op','schedule_op','editable_profile_admin','character_profile_admin',
      'mass_sending_admin','kickop_admin','editable_note_admin','answer_users_admin']
    @settings = params[:settings]
    date_errors = false
    if @settings.has_key?("schedule_start_date_op") && @settings.has_key?("schedule_end_date_op")
      start_date = @settings["schedule_start_date_op"]
      end_date = @settings["schedule_end_date_op"]
      if start_date > end_date
        date_errors = true
        @settings.delete("schedule_start_date_op")
        @settings.delete("schedule_end_date_op")
      end
    end
    checked_settings.each do |key|
      if @settings.has_key?(key)
        value = 1
      else
        value = 0
      end
      setting = Systemmeta.find_or_initialize_by_meta_key(key)
      setting.update_attributes(
        :meta_key => key,
        :meta_value => value
      )
    end
    @settings.each do | key, value |
      setting = Systemmeta.find_or_initialize_by_meta_key(key)
      unless checked_settings.include?(key)
        setting.update_attributes(
          :meta_key => key,
          :meta_value => value
        )
      end
    end  
    if date_errors 
      flash[:alert] = "can't be earlier then start date time"
    else
      flash[:success] = "Successfully updated"
    end
    redirect_to permission_admin_systemmetas_path
  end
  private
    def authorize_admin!
      unless current_operator.has_role? :admin or current_operator.has_role? :superadmin
        flash[:alert] = "You must be an admin to do that."
        redirect_to admin_schedules_path
      end
    end
end
