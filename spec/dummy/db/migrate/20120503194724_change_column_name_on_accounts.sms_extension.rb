# This migration comes from sms_extension (originally 20120110061023)
class ChangeColumnNameOnAccounts < ActiveRecord::Migration
  def change
    rename_column :sms_extension_accounts, :consumer_phone_number, :consume_phone_number
  end
end
