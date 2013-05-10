class Admin::MessagesController < ApplicationController
  layout "admin"
  before_filter :authenticate_operator!  
  
  def index
    @topics = Topic.where("recipient_id=? or sender_id = ?", current_operator.id, current_operator.id)
  end
  
  def read
#    message.read
#    render :text => "ok"
  end
  
  def create
    if params.key?(:message)
      recipient = Operator.find(params[:message][:recipient])
      topic = Topic.new
      topic.subject = params[:message][:topic]
      topic.recipient = recipient
      topic.sender = current_operator
      if topic.save
        msg = Message.new()
        msg.recipient = recipient
        msg.sender = current_operator
        msg.topic = topic
        msg.message = params[:message][:message]
        saved = msg.save
        @topics = Topic.where("recipient_id=? or sender_id = ?", current_operator.id, current_operator.id)
        render  :index
      else
        render :new
      end
    else
      topic_id = params[:topic]
      @topic = Topic.find(topic_id)
      @new_msg = Message.new()
      @new_msg.recipient = @topic.recipient_user(current_operator)
      @new_msg.topic = @topic
      @new_msg.sender = current_operator
      @new_msg.message = params["msg"]
      @saved = @new_msg.save
    end
  end
  
  def new
    @new_message =  Message.new
    @senders = Hash.new
    unless current_operator.has_role? :admin
      admins = Operator.admins
      admins.each do | user |
        @senders[user.name] = user.id
      end
    else  
      senders = Operator.senders(current_operator)
      senders.each do | user |
        @senders[user.name] = user.id
      end
    end    
    render :new
  end
  
  def topic
    @topic = Topic.find(params[:topic])
    @topic.all_read(current_operator)
    @recipient_operator = @topic.recipient_user(current_operator)
    @messages = @topic.messages.order("created_at desc")
    @new_message =  Message.new
    @new_message.topic_id = @topic.id
    render :topic   
  end
  
  def sent
    @topics = Topic.where("sender_id = ?", current_operator.id)
    render  :index
  end
  
  def update
    
  end
  
  def destroy
    message.destroy
    render :text => "ok"
  end
end
