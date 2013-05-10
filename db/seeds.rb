# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Operator.create!(:email => 'admin@hotmail.com', :password => 'caravan123', :password_confirmation => 'caravan123',:name=>'admin')
operator = Operator.first
operator.add_role :admin
Operator.create!(:email => 'superadmin@hotmail.com', :password => 'caravan123', :password_confirmation => 'caravan123',:name=>'superadmin')
operator = Operator.find_by_email('superadmin@hotmail.com')
operator.add_role :superadmin
Operator.create!(:email => 'test@hotmail.com', :password => 'caravan123', :password_confirmation => 'caravan123',:name=>'test')
#operator.confirm!