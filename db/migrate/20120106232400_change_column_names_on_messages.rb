class ChangeColumnNamesOnMessages < ActiveRecord::Migration
  def up
    rename_column :sms_extension_messages, :SmsMessageSid, :sms_message_sid
    rename_column :sms_extension_messages, :AccountSid, :account_sid
  end

  def down
    rename_column :sms_extension_messages, :sms_message_sid, :SmsMessageSid
    rename_column :sms_extension_messages, :account_sid, :AccountSid
  end
end
