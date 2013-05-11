# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130511045413) do

  create_table "apn_devices", :force => true do |t|
    t.string   "token",              :default => "", :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "last_registered_at"
  end

  add_index "apn_devices", ["token"], :name => "index_apn_devices_on_token", :unique => true

  create_table "apn_notifications", :force => true do |t|
    t.integer  "device_id",                        :null => false
    t.integer  "errors_nb",         :default => 0
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.text     "custom_properties"
    t.datetime "sent_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  create_table "chat_messages", :id => false, :force => true do |t|
    t.string   "prihash"
    t.integer  "operator_id"
    t.integer  "user_id"
    t.string   "message"
    t.boolean  "direction"
    t.integer  "session_id"
    t.string   "remote_ip"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "gcm_devices", :force => true do |t|
    t.string   "registration_id",    :null => false
    t.datetime "last_registered_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "gcm_devices", ["registration_id"], :name => "index_gcm_devices_on_registration_id", :unique => true

  create_table "gcm_notifications", :force => true do |t|
    t.integer  "device_id",        :null => false
    t.string   "collapse_key"
    t.text     "data"
    t.boolean  "delay_while_idle"
    t.datetime "sent_at"
    t.integer  "time_to_live"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "gcm_notifications", ["device_id"], :name => "index_gcm_notifications_on_device_id"

  create_table "messages", :force => true do |t|
    t.string   "message"
    t.integer  "topic_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "recipient_id"
    t.integer  "sender_id"
    t.boolean  "unread",       :default => true
  end

  add_index "messages", ["topic_id"], :name => "index_messages_on_topic_id"

  create_table "notes", :force => true do |t|
    t.string   "note"
    t.boolean  "viewable",    :default => true
    t.integer  "operator_id"
    t.integer  "user_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "operators", :force => true do |t|
    t.string   "name"
    t.string   "display_name"
    t.string   "country"
    t.string   "short_bio"
    t.string   "long_bio"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "display_avatar_file_name"
    t.string   "display_avatar_content_type"
    t.integer  "display_avatar_file_size"
    t.datetime "display_avatar_updated_at"
    t.string   "email",                       :default => "",    :null => false
    t.string   "encrypted_password",          :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "block",                       :default => false
    t.string   "mobile_number"
    t.string   "real_name"
    t.string   "languages"
    t.datetime "session_update"
  end

  add_index "operators", ["email"], :name => "index_operators_on_email", :unique => true
  add_index "operators", ["reset_password_token"], :name => "index_operators_on_reset_password_token", :unique => true

  create_table "operators_roles", :id => false, :force => true do |t|
    t.integer "operator_id"
    t.integer "role_id"
  end

  add_index "operators_roles", ["operator_id", "role_id"], :name => "index_operators_roles_on_operator_id_and_role_id"

  create_table "operators_skills", :id => false, :force => true do |t|
    t.integer "operator_id"
    t.integer "skill_id"
  end

  add_index "operators_skills", ["operator_id", "skill_id"], :name => "index_operators_skills_on_operator_id_and_skill_id"

  create_table "permissions", :force => true do |t|
    t.integer  "operator_id"
    t.boolean  "outside_shift"
    t.boolean  "notes"
    t.boolean  "order"
    t.integer  "idle_time"
    t.boolean  "schedule"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "editable_profile_admin"
    t.boolean  "character_profile_admin"
    t.boolean  "mass_sending_admin"
    t.boolean  "kickop_admin"
    t.boolean  "editable_note_admin"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "pictures", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "rates", :force => true do |t|
    t.decimal  "skill",         :precision => 10, :scale => 0
    t.decimal  "communication", :precision => 10, :scale => 0
    t.decimal  "friendliness",  :precision => 10, :scale => 0
    t.decimal  "recommend",     :precision => 10, :scale => 0
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "session_id"
  end

  create_table "reminders", :force => true do |t|
    t.string   "name"
    t.integer  "inactivity"
    t.integer  "setting_time"
    t.integer  "spread"
    t.string   "message"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "not_users",    :default => 0
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "schedules", :force => true do |t|
    t.date     "thedate"
    t.integer  "number"
    t.string   "status"
    t.integer  "operator_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "schedules", ["operator_id"], :name => "index_schedules_on_operator_id"

  create_table "sessions", :force => true do |t|
    t.datetime "start"
    t.datetime "end"
    t.integer  "user_id"
    t.integer  "operator_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.text     "chat_history", :limit => 2147483647
  end

  create_table "skills", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "operator_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "skills", ["operator_id"], :name => "index_skills_on_operator_id"

  create_table "systemmeta", :force => true do |t|
    t.string   "meta_key"
    t.string   "display_name"
    t.string   "default"
    t.string   "meta_value"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "topics", :force => true do |t|
    t.string   "subject"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "recipient_id"
    t.integer  "sender_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "display_name"
    t.string   "real_name"
    t.string   "mobile_number"
    t.string   "status"
    t.string   "credits"
    t.string   "sales"
    t.string   "bonus_credits"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "country"
    t.string   "short_bio"
    t.string   "long_bio"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "block",               :default => false
    t.string   "email"
    t.datetime "session_update"
    t.string   "encrypted_password"
    t.string   "auth_token"
    t.string   "favor_ops"
    t.string   "devicetoken"
    t.string   "devicetype"
    t.boolean  "daily_message",       :default => false
  end

end
