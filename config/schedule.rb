#job_type :rake, "{ cd #{@current_path} > /dev/null; } && RAILS_ENV=:environment bundle exec rake :task --silent :output"
#job_type :script, "{ cd #{@current_path} > /dev/null; } && RAILS_ENV=:environment bundle exec script/:task :output"
#job_type :runner, "{ cd #{@current_path} > /dev/null; } && RAILS_ENV=:environment bundle exec rails runner ':task' :output"

every :hour do # Many shortcuts available: :hour, :day, :month, :year, :reboot
  runner "Reminder.send_message"
end

every :day, :at => '12:20am' do
  runner "Systemmeta.push_user_daily_messages"
end