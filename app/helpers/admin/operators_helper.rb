module Admin::OperatorsHelper
  def diff_duration(secs)
    secs  = secs.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      "#{days} days and #{hours % 24} hours"
    elsif hours > 0
      "#{hours}:#{mins % 60}:#{secs % 60}"
    elsif mins > 0
      "00:#{mins}:#{secs % 60}"
    elsif secs >= 0
      "00:00:#{secs}"
    end
  end
def shift_status(shift, thedate, number)
    today = Date.today
    if today > thedate or (today == thedate and Time.now.strftime("%H").to_i > number)
      case shift.status
      when "booked"
        return "Absence"
      when "attend"
        return "Attendance"
      when  "late"
        return "Late"
      when "holiday"
        return "Holiday"
      when "cancel_by_admin" 
        return "Cancel by Admin"
      else
        return ""
      end
    elsif shift.status
      case shift.status
      when "booked"
        return "Booked"
      when "holiday"
        return "Holiday"
      when "cancel_by_admin" 
        return "Cancel by Admin"
      else
        return ""
      end
    end
  end  
end
