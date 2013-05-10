class Message < ActiveRecord::Base
  belongs_to :topic
  belongs_to :recipient, :class_name => "Operator"
  belongs_to :sender, :class_name => "Operator"
  attr_accessible :message,:sender_id,:recipient_id,:topic_id, :unread
  #scope :topic, lambda{ | topic_id | self.where(:topic_id => topic_id).order("created_at DESC")  }
end
