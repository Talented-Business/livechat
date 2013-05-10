class Role < ActiveRecord::Base
  has_and_belongs_to_many :operators, :join_table => :operators_roles
  belongs_to :resource, :polymorphic => true
  
  scopify
  # attr_accessible :title, :body
end
