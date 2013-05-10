class Permission < ActiveRecord::Base
  belongs_to :operator
  attr_accessible :idle_time, :notes, :order, :outside_shift, :schedule, :start_date,:end_date, :operator_id,
          :editable_profile_admin, :character_profile_admin, :mass_sending_admin, :kickop_admin, :editable_note_admin
  validate :permission_start_end_datetime

  def permission_start_end_datetime
    if start_date.present? && end_date.present?
      if start_date > end_date
        errors.add(:end_date, "can't be earlier then start date time")
      end
    end
  end
  
end
