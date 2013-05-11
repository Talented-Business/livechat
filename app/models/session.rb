class Session < ActiveRecord::Base
  belongs_to  :operator
  belongs_to  :user
  has_many    :chat_messages
  attr_accessible :end, :start, :chat_history
  validates :start, :presence => true
  validate :start_end_datetime
  has_one   :rate
  serialize :chat_history, Array

  def start_end_datetime
    if self.start.present? && self.end.present?
      if self.start > self.end
        errors.add(:end, "can't be earlier then start date time")
      end
    end
  end
  def self.check_sessions
    active_sessions = Session.where(:end=>nil)
    active_sessions.each do |s|
      s.check_status
    end
  end
  def check_status
    default_time = Systemmeta.get_setting("session_end_time")
    default_time = default_time.to_i
    if default_time < 1
      default_time = 30
      key = "session_end_time"
      setting = Systemmeta.find_or_initialize_by_meta_key(key)
      setting.update_attributes(
        :meta_key => key,
        :meta_value => default_time
      )      
    end
    return false unless self.end.nil?
    last_chat = self.chat_messages.last
    if !last_chat.nil? && last_chat.created_at.to_datetime + 15.minutes < DateTime.now
      save_history
      self.update_attribute(:end, last_chat.created_at.to_datetime+ 15.minutes)
      return false
    end
    return true
  end
  def end_session
    save_history
    self.update_attribute(:end, DateTime.now)
  end
  def get_remote_ip
    if self.end.nil?
      return self.chat_messages.where(:direction=>false).last.remote_ip
    else
      self.chat_history.reverse_each do |chat|
        return chat[:remote_ip] unless chat[:remote_ip].nil?
      end
    end
  end
  def self.active_session(op, user)
    active_session = where("operator_id = ? and user_id = ?",op.id, user.id).where(:end=>nil).last
  end
  private
  def save_history
    chats = []
    self.chat_messages.each do |chat_message|
      chat = Hash.new
      chat[:created_at] = chat_message.created_at
      chat[:direction] = chat_message.direction
      chat[:user] = chat_message.user.name
      chat[:operator] = chat_message.operator.name
      chat[:message] = chat_message.message
      chat[:remote_ip] = chat_message.remote_ip
      chats.push chat
    end
    ChatMessage.where("session_id = ?", self.id).delete_all
    self.chat_history = chats
    self.save
  end
end
