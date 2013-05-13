class Systemmeta < ActiveRecord::Base
  attr_accessible :default, :display_name, :meta_key, :meta_value
  validates :meta_key, :uniqueness => true
 
  def event_start_end_datetime
  end
  def self.get_setting(name)
    setting = Systemmeta.find_or_initialize_by_meta_key(name)
    return setting.meta_value
  end
  def self.push_user_daily_messages
    unless Systemmeta.get_setting("user_daily_message") ==  Systemmeta.get_setting("_user_daily_message")
      setting = Systemmeta.find_or_initialize_by_meta_key("_user_daily_message")
      setting.update_attributes(
        :meta_key => "_user_daily_message",
        :meta_value => Systemmeta.get_setting("user_daily_message")
      )
      user_daily_message = Systemmeta.get_setting("user_daily_message")
      users = User.where(:daily_message=>false)
      User.daily_messages(user_daily_message)
    end    
  end
end
