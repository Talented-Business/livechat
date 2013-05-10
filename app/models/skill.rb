class Skill < ActiveRecord::Base
  has_and_belongs_to_many :operators, :join_table => :operators_skills
  attr_accessible :description, :name
  validates :name, :presence => true  
  validates :name, :uniqueness => { :case_sensitive => false }
end
