class Admin::ChatMessagesController < ApplicationController
  include ActionView::Helpers::DateHelper
  include ApplicationHelper
  layout "admin"
  def index
    if session.has_key?(:chat_user_id)
      @user = User.find(session[:chat_user_id])
    else
      @user = nil
    end
    if params.has_key?(:user_id)
      @user = User.find(params[:user_id])
      session[:chat_user_id] = params[:user_id]
    end
    @chat_user = User.find(session[:chat_user_id])
    @chat_messages = ChatMessage.where("created_at >= ? and user_id = ? and operator_id = ?",session[:read_time]-1.days,session[:chat_user_id],current_operator.id)
    session[:read_time] = DateTime.now
    respond_to do |format|
      format.js 
    end
  end
  def show
    case params[:id]
    when 'received'
      @tab = "received"
      #@chat_messages = current_operator.received_messages.order(:created_at).reverse
      render :index and return 
    when 'sent'
      @tab = "sent"
      #@chat_messages = current_operator.sent_messages.order(:created_at).reverse
      render :index and return 
    else
      session[:read_time] = DateTime.now
      @chat_messages = ChatMessage.where("created_at >= ? and user_id = ? and operator_id = ?",session[:read_time]-1.days,session[:chat_user_id],current_operator_id)
      #@chat_message.update_attributes({
      #  :seen => true,
      #  :seen_at => DateTime.now
      #}) if @chat_message.receiver_id==current_operator.id

      #@tab = @chat_message.user.id == current_operator.id ? 'sent' : 'received'
      #@reject = current_operator.rejected_users.build :rejected_user_id => @chat_message.user.id, :message_id=>@chat_message.id
      #@accept = current_operator.accepted_users.build :accepted_user_id=>@chat_message.user.id, :message_id=>@chat_message.id
      render :index and return
    end

  end
  # POST /chat_messages
  # POST /chat_messages.json
  def create
    if session.has_key?(:chat_user_id)
      @user = User.find(session[:chat_user_id])
      @chat_message = ChatMessage.new(params[:chat_message])
      @chat_message.direction = true
      @chat_message.operator = current_operator
      @chat_message.user = @user
      msg = Hash.new
      msg['message'] = params[:chat_message][:message]
      msg['datetime'] = DateTime.now.to_s
      case @user.devicetype
      when "android"
        @user.send_android_notification(msg,'1002') unless @user.devicetoken.nil?
      when "iphone", "iPhone"  
        message = "New Message" + current_operator.name+params[:chat_message][:message].to_s
        @user.send_ios_push(message,msg) unless @user.devicetoken.nil?
      end
      
      if @chat_message.save
        respond_to do |format|
          format.js { render action: "create" } and return
        end
      end
    else
      @user = nil
    end
    render :js => "alert('failed');" 
  end
  def get_chat_users
    users = User.all#where("session_update >= ?", DateTime.now - 1.hours) 
    chat_users = []
    users.each do |user|
      _user = Hash.new
      _user['id'] = user.id
      if user.session_update.nil?
        _user['waiting'] = time_ago_in_words(user.created_at.to_datetime)#((DateTime.now - user.created_at.to_datetime)*1.days).to_i
      else
        _user['waiting'] = time_ago_in_words(user.session_update.to_datetime)#((DateTime.now - user.created_at.to_datetime)*1.days).to_i
      end      
      _user['name'] = user.name
      chat_users.push  _user
    end
    new_messages = []
    unless session.has_key?(:chat_user_id)
      session[:chat_user_id] = User.first.id
      session[:chat_user_id] = ChatMessage.last.user.id unless ChatMessage.last.nil?
    end
    if session.has_key?(:read_time) 
      #new_chats = ChatMessage.where("created_at >= ? and user_id = ?",session[:read_time],session[:chat_user_id])
      if session.has_key?(:new_message) 
        new_chats = ChatMessage.where("created_at >= ? and user_id = ? and operator_id = ? and direction = false and prihash != ?",session[:read_time],session[:chat_user_id], current_operator.id, session[:new_message])
      else
        new_chats = ChatMessage.where("created_at >= ? and user_id = ? and operator_id = ? and direction = false",session[:read_time],session[:chat_user_id], current_operator.id)
      end
      new_chats.each do |chat|
        new_message = Hash.new
        new_message['message'] = chat.message
        new_message['name'] = chat.user.name
        #new_message.waiting = DateTime.now - chat.created_at
        new_message['created_at'] = chat.created_at
        new_messages.push  new_message
        session[:new_message] = chat.id
      end
    end
    session[:read_time] = DateTime.now
    current_operator.update_attribute(:session_update, DateTime.now)
    render :json=>{:users=>chat_users, :new_messages=>new_messages }
  end
  def destroy
    @chat_message = ChatMessage.find(params[:id])
    @chat_message.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
  
end