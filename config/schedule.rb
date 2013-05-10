every :hour do # Many shortcuts available: :hour, :day, :month, :year, :reboot
  runner "Reminder.send_message"
end

every :day, :at => '12:20am' do
  runner "Systemmeta.push_user_daily_messages"
end