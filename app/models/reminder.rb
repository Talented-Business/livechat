class Reminder < ActiveRecord::Base
  include ApplicationHelper
  INTERVALS = [3,5,8,15,30]
  attr_accessible :inactivity, :message, :name, :spread, :setting_time,:not_users
  def self.possible_days
    p_days = INTERVALS
    reminders = Reminder.all
    reminders.each do |r|
      p_days.delete(r.inactivity)
    end
    return p_days
  end
  def setted_time
    if self.setting_time >12
      t = (self.setting_time-12).to_s
      t = t+":00 PM"
    else
      t = self.setting_time.to_s
      t = "0"+t if t.length==1
      t = t+":00 AM"
    end
  end
  def self.push_message
    type = '1001'
    users = User.where(:block=>false)
    android_tokens = []
    users.each do | user |
      if user.devicetype == "android" 
        android_tokens.push user.devicetoken 
      else
        ios_users.push user
      end
    end
    data = Hash.new          
    start_time = Time.now
    data['message'] = self.message
    if android_tokens.count>0
      User.send_android_notifications(android_tokens, data, type)
    end
    if self.spread.minutes + start_time > Time.now
      self.update_attribute(:not_users, users.count - android_tokens.count)
      return
    end
    user_count = 0
    if ios_users.count>0
      ios_users.each do |user|
        user.send_ios_push(msgarr.to_json, {},type)
        user_count = user_count + 1
        if self.spread.minutes + start_time > Time.now
          self.update_attribute(:not_users, users.count - android_tokens.count - user_count)
          return
        end
      end
    end
  end
  def self.test_push_message
    (0..100).each do |i|
      if i >50
        puts i
        return
      end
    end
  end
end
