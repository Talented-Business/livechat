module Admin::MessagesHelper
  def topic_name(topic,user)
    if topic.sender == user
      topic.recipient.name
    else
      topic.sender.name
    end
  end  
end
