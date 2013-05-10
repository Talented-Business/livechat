class Systemmeta < ActiveRecord::Base
  attr_accessible :default, :display_name, :meta_key, :meta_value
  validates :meta_key, :uniqueness => true
 
  def event_start_end_datetime
  end
  def self.get_setting(name)
    setting = Systemmeta.find_or_initialize_by_meta_key(name)
    return setting.meta_value
  end
end
