class Rate < ActiveRecord::Base
  belongs_to :operator
  belongs_to :user
  attr_accessible :skill, :communication, :friendliness, :recommend,:user_id, :operator_id
end
