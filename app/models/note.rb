class Note < ActiveRecord::Base
  belongs_to :operator
  belongs_to :user
  attr_accessible :note, :viewable
  validates :note, :length => {:minimum   => 1, :maximum => 500 }
end
