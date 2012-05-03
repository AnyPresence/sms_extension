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

ActiveRecord::Schema.define(:version => 20120503201046) do

  create_table "sms_extension_accounts", :force => true do |t|
    t.string   "application_id"
    t.string   "phone_number"
    t.string   "field_name"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "consume_phone_number"
    t.text     "permitted_phone_numbers"
    t.string   "api_version"
    t.string   "extension_id"
    t.string   "api_host"
    t.string   "api_token"
  end

  add_index "sms_extension_accounts", ["application_id"], :name => "index_sms_extension_accounts_on_application_id", :unique => true

  create_table "sms_extension_bulk_text_phone_numbers", :force => true do |t|
    t.string   "name"
    t.string   "format"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
  end

  create_table "sms_extension_menu_options", :force => true do |t|
    t.string   "name"
    t.string   "format"
    t.integer  "account_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "type"
  end

  create_table "sms_extension_messages", :force => true do |t|
    t.string   "sms_message_sid"
    t.string   "account_sid"
    t.string   "body"
    t.string   "from"
    t.string   "to"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "sms_extension_outgoing_text_options", :force => true do |t|
    t.string   "name"
    t.string   "format"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "account_id"
  end

end
