module Admin::SchedulesHelper
  def is_bookable(statuses, thedate, number)
    status = Hash.new
    op_count = Schedule::OPCOUNT
    count = 0
    statuses.each do |s|
      if s.operator_id > 0
        case s.status 
        when "attend"
          status["attend"] = s.operator_id
        when "lates"
          status["lates"] = s.operator_id
        when "booked"
          status["booked"] = s.operator_id
          count = count+1
        when "cancel_by_admin"
          status["cancel_by_admin"] = s.operator_id
        else 
          status["other"] = s.operator_id
        end  
      elsif s.operator_id == 0
        op_count = s.status.to_i
      end
      if s.operator_id == current_operator.id
        status["own"] = s.status
      end  
    end unless statuses.nil?
    today = Date.today
    if today > thedate or (today == thedate and Time.now.strftime("%H").to_i > number)
      case status["own"] 
      when "booked"
        return "absence"
      when "attend","late"
        return status["own"]
      else
        return ""
      end
    elsif status["own"]
      case status["own"]
      when "cancel_by_admin"
        return ""
      else
        return status["own"] 
      end
    end
    if op_count > count    
      return "bookable"
    else 
      return "full"
    end
  end
  def books_analyse(statuses, thedate, number)
    status = Hash.new
    statuses.each do |s|
      if s.operator.has_role? :admin
        
      else
        if s.operator_id > 0
          case s.status 
          when "attend"
            status["attend"] = s.operator_id
          when "lates"
            status["lates"] = s.operator_id
          when "booked"
            status["booked"] = s.operator_id
          when "cancel_by_admin"
            status["cancel_by_admin"] = s.operator_id
          else 
            status["other"] = s.operator_id
          end  
        end
        if s.operator_id == current_operator.id
          status["own"] = s.status
        end  
      end
    end unless statuses.nil?
    today = Date.today
    if today > thedate
      return ""
    elsif today == thedate and Time.now.strftime("%H").to_i > number
      return ""
    elsif status["own"]
      return status["own"]
    else  
      return "bookable"
    end
  end
end
