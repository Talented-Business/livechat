class Topic < ActiveRecord::Base
  has_many  :messages, :dependent => :destroy
  belongs_to :recipient, :class_name => "Operator"
  belongs_to :sender, :class_name => "Operator"
  attr_accessible :subject,:sender_id,:recipient_id
  validates :subject, :presence => true  

  def last_message
    Message.where(:topic_id=>self.id).order("created_at ASC").last
  end  
  def count
    Message.where(:topic_id=>self.id).count
  end
  def self.sent(user)
    messages = Message.where(:sender_id=>user.id)
    topics = Array.new
    if messages.count > 0
      messages.each do |m|
        topics << m.topic
      end
      topics.uniq!
    end
    return topics
  end
  def all_read(user)
    messages = self.messages.where(:recipient_id => user.id,:unread => true).update_all(:unread=>false)
  end
  def recipient_user(user)
    case user
    when self.sender
      return self.recipient
    when self.recipient
      return self.sender
    end
    return nil
  end
  
end
