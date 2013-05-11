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
Systemmeta.create!(:meta_key => 'min_length', :meta_value => '1')
Systemmeta.create!(:meta_key => 'max_length', :meta_value => '144')
Systemmeta.create!(:meta_key => 'waiting_time', :meta_value => '10')
Systemmeta.create!(:meta_key => 'inactivity_time', :meta_value => '10')
Systemmeta.create!(:meta_key => 'late_setting', :meta_value => '5')
Systemmeta.create!(:meta_key => 'max_users_per_request', :meta_value => '10')
Systemmeta.create!(:meta_key => 'allow_cancel', :meta_value => '10')
Systemmeta.create!(:meta_key => 'target_hours', :meta_value => '5')
Systemmeta.create!(:meta_key => 'notes_stored', :meta_value => '10')
Systemmeta.create!(:meta_key => 'free_credits', :meta_value => '5')
Systemmeta.create!(:meta_key => 'free_credits', :meta_value => '5')