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

ActiveRecord::Schema.define(:version => 20120517181335) do

  create_table "accounts", :force => true do |t|
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.string   "application_id"
    t.string   "phone_number"
    t.string   "field_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "consume_phone_number"
    t.text     "permitted_phone_numbers"
    t.string   "api_version"
    t.string   "extension_id"
    t.string   "api_host"
    t.string   "api_token"
  end

  add_index "accounts", ["application_id"], :name => "index_accounts_on_application_id", :unique => true
  add_index "accounts", ["authentication_token"], :name => "index_accounts_on_authentication_token", :unique => true

  create_table "bulk_text_phone_numbers", :force => true do |t|
    t.string   "name"
    t.string   "format"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "menu_options", :force => true do |t|
    t.string   "name"
    t.string   "format"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "phone_number_field"
    t.string   "display_name"
    t.string   "display_key"
  end

  create_table "messages", :force => true do |t|
    t.string   "sms_message_sid"
    t.string   "account_sid"
    t.string   "body"
    t.string   "from"
    t.string   "to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outgoing_text_options", :force => true do |t|
    t.string   "name"
    t.string   "format"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
