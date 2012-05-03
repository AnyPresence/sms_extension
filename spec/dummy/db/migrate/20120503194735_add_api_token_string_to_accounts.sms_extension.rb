# This migration comes from sms_extension (originally 20120208190311)
class AddApiTokenStringToAccounts < ActiveRecord::Migration
  def change
    add_column :sms_extension_accounts, :api_token, :string
  end
end
