class ChangeColumnNameOnAccounts < ActiveRecord::Migration
  def change
    rename_column :sms_extension_accounts, :consumer_phone_number, :consume_phone_number
  end
end
