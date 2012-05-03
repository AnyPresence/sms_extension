# This migration comes from sms_extension (originally 20120109190423)
class AddConsumerPhoneNumberFieldOnAccounts < ActiveRecord::Migration
  def up
    add_column :sms_extension_accounts, :consumer_phone_number, :string
  end

  def down
    remove_column :sms_extension_accounts, :consumer_phone_number, :string
  end
end
