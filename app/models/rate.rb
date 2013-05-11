class Rate < ActiveRecord::Base
  belongs_to :operator
  belongs_to :session
  attr_accessible :skill, :communication, :friendliness, :recommend,:session_id, :operator_id
end
