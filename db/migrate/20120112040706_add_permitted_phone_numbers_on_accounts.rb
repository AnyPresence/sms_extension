class AddPermittedPhoneNumbersOnAccounts < ActiveRecord::Migration
  def up
    add_column :sms_extension_accounts, :permitted_phone_numbers, :text
  end

  def down
    remove_column :sms_extension_accounts, :permitted_phone_numbers, :text
  end
end
