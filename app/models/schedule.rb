class Schedule < ActiveRecord::Base
  belongs_to :operator
  attr_accessible :number, :thedate, :status, :operator_id
  validates :number, :numericality => { :only_integer => true, :greater_than_or_equal_to=>0, :less_than=>25 }
  validates_uniqueness_of :operator_id, :scope => [:thedate, :number]  
  OPCOUNT = 3
  def current_status
    today = Date.today
    if today > self.thedate or (today == self.thedate and Time.now.strftime("%H").to_i >= self.number)
      return "absence" if self.status == "booked"
    end 
    return self.status
  end
  def self.workable_ops
    ops = where(:thedate=>Date.today, :number=>Time.now.strftime("%H").to_i).where("status='attend' or status='late' or status='booked'" )
  end
end
