# This migration comes from sms_extension (originally 20120106232400)
class ChangeColumnNamesOnMessages < ActiveRecord::Migration
  def up
    rename_column :messages, :SmsMessageSid, :sms_message_sid
    rename_column :messages, :AccountSid, :account_sid
  end

  def down
    rename_column :messages, :sms_message_sid, :SmsMessageSid
    rename_column :messages, :account_sid, :AccountSid
  end
end
