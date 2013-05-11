class Admin::SchedulesController < ApplicationController
  layout "admin"
  before_filter :authenticate_operator!  
  before_filter :authorize_admin! , :only => [:rota_index,:cancel]
  def index
    @thedate = Date.today
    @thedate = params[:date].to_date if params[:date]
    begindate = @thedate.beginning_of_week
    @schedules = Array.new
    @allow_cancel = Systemmeta.get_setting('allow_cancel')
    @op_schedules = []
    (0..6).each do |w|
      @schedules[w] = Array.new
      @op_schedules[w] = []
      (0..23).each do |num|
        @schedules[w][num] = Schedule.where(:thedate=>begindate+w, :number=>num)
        @op_schedules[w][num] = Schedule.where(:thedate=>begindate+w, :number=>num, :operator_id=>current_operator.id).first_or_initialize
      end  
    end    
  end
  def rota_index
    @thedate = Date.today
    @thedate = params[:date].to_date if params[:date]
    begindate = @thedate.beginning_of_week
    @schedules = Array.new
    @op_schedules = []
    (0..6).each do |w|
      @schedules[w] = Array.new
      @op_schedules[w] = []
      (0..23).each do |num|
        @schedules[w][num] = Hash.new
        record = Schedule.where(:thedate=>begindate+w, :number=>num, :operator_id =>0).first
        op_count = Schedule::OPCOUNT
        op_count = record.status unless record.nil?
        @schedules[w][num][:total_count] =  op_count
        statuses = Schedule.where(:thedate=>begindate+w, :number=>num )
        today = Date.today
        if today > begindate+w
          attend_count = Schedule.where(:thedate=>begindate+w, :number=>num, :status=>"attend" ).count
          late_count = Schedule.where(:thedate=>begindate+w, :number=>num, :status=>"late" ).count
          absent_count = Schedule.where(:thedate=>begindate+w, :number=>num, :status=>"booked" ).count
          current_count = attend_count + late_count + absent_count
        elsif today == (begindate+w) and Time.now.strftime("%H").to_i >= num
          attend_count = Schedule.where(:thedate=>begindate+w, :number=>num, :status=>"attend" ).count
          late_count = Schedule.where(:thedate=>begindate+w, :number=>num, :status=>"late" ).count
          absent_count = Schedule.where(:thedate=>begindate+w, :number=>num, :status=>"booked" ).count
          current_count = attend_count + late_count + absent_count
        else  
          current_count = Schedule.where(:thedate=>begindate+w, :number=>num, :status=>"booked" ).count
        end
        @schedules[w][num][:count] =  current_count
      end  
    end    
    @number = Time.now.strftime("%H").to_i
    @schedules_per_slot = Schedule.where(:thedate=>@thedate, :number=>@number )
    @op_count = Schedule::OPCOUNT
    record = Schedule.where(:thedate=>@thedate, :number=>@number, :operator_id =>0).first
    @op_count = record.status unless record.nil?
    @operators = Operator.operators
  end
  def show
  end
  def rota_slot
    @thedate = params[:date].to_date
    @number = params[:number].to_i
    @schedules_per_slot = Schedule.where(:thedate=>@thedate, :number=>@number )
    @op_count = Schedule::OPCOUNT
    record = Schedule.where(:thedate=>@thedate, :number=>@number, :operator_id =>0).first
    @op_count = record.status unless record.nil?
    @td_id = nil
    render :action=>:rota_slot, :layout=>nil
  end
  def new
  end
  def cancel
    schedule = Schedule.find(params[:schedule])
    today = Date.today
    if today < schedule.thedate or (today == schedule.thedate and Time.now.strftime("%H").to_i < schedule.number)
      case schedule.current_status
      when "booked"
        schedule.status = "cancel_by_admin"
      when "cancel_by_admin"
        schedule.status = "booked"
      end  
      schedule.save
    end
    @thedate = schedule.thedate
    @number = schedule.number.to_i
    @week = @thedate.strftime("%u").to_i - 1
    record = Schedule.where(:thedate=>@thedate, :number=>@number, :operator_id =>0).first
    op_count = Schedule::OPCOUNT
    op_count = record.status unless record.nil?
    @total_count =  op_count
    statuses = Schedule.where(:thedate=>@thedate, :number=>@number )
    today = Date.today
    if today > @thedate or (today == @thedate and Time.now.strftime("%H").to_i > @number )
      attend_count = Schedule.where(:thedate=>@thedate, :number=>@number, :status=>"attend" ).count
      late_count = Schedule.where(:thedate=>@thedate, :number=>@number, :status=>"late" ).count
      absent_count = Schedule.where(:thedate=>@thedate, :number=>@number, :status=>"booked" ).count
      @current_count = attend_count + late_count + absent_count
    else  
      @current_count = Schedule.where(:thedate=>@thedate, :number=>@number, :status=>"booked" ).count
    end
    s=""
    if @current_count > 0
      s = "full_fill"
      if @total_count.to_i > @current_count
        s = "full_not"
      end
    end
    @td_id = 'td_'+@week.to_s+'_'+@number.to_s
    @schedules_per_slot = Schedule.where(:thedate=>@thedate, :number=>@number )
    @op_count = Schedule::OPCOUNT
    record = Schedule.where(:thedate=>@thedate, :number=>@number, :operator_id =>0).first
    @op_count = record.status unless record.nil?
    render :action=>:rota_slot, :layout=>nil
  end
  def add_operator
    op_count = params[:op_count]
    op_name  = params[:op_name]
    @thedate = params[:thedate].to_date
    @number = params[:number].to_i
    if op_count.to_i > 0
      s = Schedule.where(:thedate=>@thedate, :number=>@number, :operator_id =>0).first_or_create!(:status=>op_count)
      s.update_attributes(
        :status=>op_count
      )
    end
    operator = Operator.find_by_name(op_name)
    unless operator.nil?
      Schedule.where(:thedate=>@thedate, :number=>@number, :operator_id =>operator.id).first_or_create!(:status=>"booked")
    end
    @week = @thedate.strftime("%u").to_i - 1
    record = Schedule.where(:thedate=>@thedate, :number=>@number, :operator_id =>0).first
    op_count = Schedule::OPCOUNT
    op_count = record.status unless record.nil?
    @total_count =  op_count
    statuses = Schedule.where(:thedate=>@thedate, :number=>@number )
    today = Date.today
    if today > @thedate or (today == @thedate and Time.now.strftime("%H").to_i > @number )
      attend_count = Schedule.where(:thedate=>@thedate, :number=>@number, :status=>"attend" ).count
      late_count = Schedule.where(:thedate=>@thedate, :number=>@number, :status=>"late" ).count
      absent_count = Schedule.where(:thedate=>@thedate, :number=>@number, :status=>"booked" ).count
      @current_count = attend_count + late_count + absent_count
    else  
      @current_count = Schedule.where(:thedate=>@thedate, :number=>@number, :status=>"booked" ).count
    end
    s=""
    if @current_count > 0
      s = "full_fill"
      if @total_count.to_i > @current_count
        s = "full_not"
      end
    end
    @td_id = 'td_'+@week.to_s+'_'+@number.to_s
    @schedules_per_slot = Schedule.where(:thedate=>@thedate, :number=>@number )
    @op_count = Schedule::OPCOUNT
    record = Schedule.where(:thedate=>@thedate, :number=>@number, :operator_id =>0).first
    @op_count = record.status unless record.nil?
    render :action=>:rota_slot, :layout=>nil
  end
  def create
    @schedule = Schedule.new(params[:schedule])
    @schedule.status = "booked"
    @schedule.save
    @element_id = params[:element_id]
    @allow_cancel = Systemmeta.get_setting('allow_cancel')
    render :action=>:create, :layout=>nil
    #render :js=>"alert('success!');" and return
  end
  def update
  end
  def destroy
    @sh = Schedule.find(params[:schedule][:id])
    @sh.destroy
    params[:schedule].delete(:id)
    @schedule = Schedule.new(params[:schedule])
    @element_id = params[:element_id]
    render :action=>:destroy, :layout=>nil
  end
  def work_page
    current_hour = Time.now.strftime("%H").to_i
    today = Date.today
    record = Schedule.where(:thedate=>today, :number=>current_hour, :operator_id=>current_operator.id).first
    if record.nil?
      #"your page block"
      @working_status = false;
    else 
      case record.status
      when "booked"
        late_time = Systemmeta.get_setting('late_setting')
        current_minute = Time.now.strftime("%M").to_i
        if current_minute > late_time.to_i 
          record.status = "late"
        else  
          record.status = "attend"
        end
        record.save
        @working_status = true
      when "late","attend"  
        @working_status = true
      else
        @working_status = false
      end
    end
    @new_chat = ChatMessage.new
    @users = User.all
    @active_sessions = current_operator.active_sessions
    unless session.has_key?(:chat_user_id) || User.first.nil?
      session[:chat_user_id] = User.first.id
      session[:chat_user_id] = ChatMessage.last.user.id unless ChatMessage.last.nil?
    end    
    session[:read_time] = DateTime.now
    begin
      if session.has_key?(:chat_user_id)
        @chat_user = User.find(session[:chat_user_id]) 
        #@chat_messages = ChatMessage.where("created_at >= ? and user_id = ? and operator_id = ?",session[:read_time]-1.days,session[:chat_user_id],current_operator.id)
        active_session = Session.active_session(current_operator,@chat_user)
        if active_session.nil?
          @chat_messages = []
        else
          @chat_messages = active_session.chat_messages
        end
        @notes = Note.where("viewable = true and user_id = ? and operator_id = ?",session[:chat_user_id],current_operator.id)
      end
    rescue
      session.delete(:chat_user_id) 
      @chat_messages = []
    end
  end
  def request_holidays
    start_date  = Date.strptime(params[:start_date],"%m/%d/%Y")
    start_date =  Date.today +1 if start_date <= Date.today
    end_date    = Date.strptime(params[:end_date],"%m/%d/%Y")
    setting     = params[:setting]
    if start_date <= end_date
      case setting
      when "set"
        (start_date..end_date).each do |d|
          (0..23).each do |num|
            schedule = Schedule.where(:thedate=>d, :number=>num, :operator_id=>current_operator.id).first_or_initialize(:thedate=>d, :number=>num, :operator_id=>current_operator.id)
            schedule.update_attributes(
              :status => "holiday"
            )
          end  
        end
      when "unset"  
        schedules = Schedule.where(:thedate=>(start_date)..(end_date), :operator_id=>current_operator.id, :status=>"holiday")
        schedules.each do |s|
          s.destroy
        end
      end
    end  
    redirect_to admin_schedules_path
  end
  def book
  end
  def note
    note = Note.new
    note.user = User.find(session[:chat_user_id])
    note.operator = current_operator
    note.note = params[:note]
    note.save
    @notes = Note.where("viewable = true and user_id = ?",session[:chat_user_id])
    render :action=>:note, :layout=>nil
  end
  private
    def authorize_admin!
      unless current_operator.has_role? :admin or current_operator.has_role? :superadmin
        flash[:alert] = "You must be an admin to do that."
        redirect_to admin_schedules_path
      end
    end
end
